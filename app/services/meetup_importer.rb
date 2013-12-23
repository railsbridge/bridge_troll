require 'net/http'
require_relative 'meetups'

class MeetupImporter
  def sanitize str
    # 'UTF-16' by itself works locally, but not on Heroku. 'LE' means 'little endian'.
    str.encode('UTF-16LE', undef: :replace, invalid: :replace, :replace => '').encode('UTF-8')
  end

  def show_message message
    puts ('-' * 40) + "\n" + message + ('-' * 40)
  end

  def assert_key_exists
    return true if ENV['MEETUP_API_KEY']

    show_message <<-MESSAGE
No API key found!

Find your Meetup account's API key at http://www.meetup.com/meetup_api/key/
then add it to your .env file as MEETUP_API_KEY=your_api_key_goes_here
MESSAGE
    return false
  end

  def assert_valid_status url, response
    return true if response.code == '200'

    show_message <<-MESSAGE
The meetup API request did not return a successful status
url: #{url}

Status Code #{response.code}
MESSAGE

    return false
  end

  def assert_valid_response url, response_json
    return true unless response_json['problem']

    show_message <<-MESSAGE
The meetup API request had some sort of error:
url: #{url}

    #{response_json['problem']}
    #{response_json['details']}
MESSAGE
    return false
  end

  def all_meetup_events
    MEETUP_EVENTS.values.flatten
  end

  def import group = nil
    return unless assert_key_exists

    events = group ? MEETUP_EVENTS[group] : all_meetup_events
    events.each_with_index do |event_data, index|
      puts "Importing event #{index+1} of #{events.length} (students: #{event_data[:student_event_id]}, volunteers: #{event_data[:volunteer_event_id]})"
      import_student_and_volunteer_event(event_data)
    end
  end

  def import_single student_event_id
    return unless assert_key_exists

    event_data = all_meetup_events.find { |event| event[:student_event_id] == student_event_id.to_i }
    raise "No event data found for #{student_event_id}" unless event_data.present?

    puts "Importing event (students: #{event_data[:student_event_id]}, volunteers: #{event_data[:volunteer_event_id]})"
    import_student_and_volunteer_event(event_data)
  end

  def import_student_and_volunteer_event event_data
    event = import_event(
      name: event_data[:name],
      event_id: event_data[:volunteer_event_id],
      chapter_name: event_data[:chapter_name],
      finder_key: :meetup_volunteer_event_id,
      rsvp_role: Role::VOLUNTEER
    )
    import_event(
      name: event_data[:name],
      event_id: event_data[:student_event_id],
      chapter_name: event_data[:chapter_name],
      event: event,
      finder_key: :meetup_student_event_id,
      rsvp_role: Role::STUDENT
    )
  end

  def import_event options
    event_json = get_api_response_for("/2/event/#{options[:event_id]}")
    return unless event_json
    unless event_json['venue']
      puts "Missing venue for #{options[:event_id]}. Send help!"
      return
    end

    location = import_venue(event_json['venue'], options[:chapter_name])

    event = options[:event] || Event.where(options[:finder_key] => options[:event_id]).first_or_initialize
    event.update_attributes(
      title: options[:name],
      details: sanitize(event_json['description']),
      time_zone: 'Pacific Time (US & Canada)',
      location: location,
      options[:finder_key] => options[:event_id]
    )

    unless event.event_sessions.present?
      event_start = Time.at(event_json['time'].to_i / 1000)
      event.event_sessions << EventSession.new(name: 'Installfest + Workshop', starts_at: event_start, ends_at: event_start + 1.day)
    end
    event.save!

    import_rsvps(event, options[:finder_key], options[:rsvp_role])

    event
  end

  def import_rsvps event, finder_key, rsvp_role
    event_id = event.send(finder_key)
    rsvp_json = get_api_response_for('/2/rsvps', {
      event_id: event_id,
      fields: 'host'
    })
    return unless rsvp_json

    rsvp_json['results'].each do |rsvp|
      meetup_id = rsvp['member']['member_id']
      role = rsvp['host'] ? Role::ORGANIZER : rsvp_role

      user = find_user(meetup_id)

      if keep_rsvp?(rsvp, role)
        user.update_attributes(full_name: rsvp['member']['name']) if user.class == MeetupUser
        create_or_update_rsvp(user, event, role)
      else
        remove_rsvp(user, event, role)
      end
    end
  end

  def keep_rsvp?(rsvp, role)
    return true if role == Role::ORGANIZER

    if role == Role::VOLUNTEER
      (rsvp['response'] == 'yes') || (rsvp['response'] == 'waitlist')
    else
      (rsvp['response'] == 'yes')
    end
  end

  def dump_events group = :sf
    group_id = MEETUP_GROUPS[group][:id]
    raise "No group found to dump events for!" unless group_id

    start_milis = DateTime.parse('2009-06-01').to_i * 1000
    puts "Fetching first set of results for #{group}..."
    event_jsons = get_api_response_for('/2/events', {
      group_id: group_id,
      time: "#{start_milis},",
      status: 'past'
    })['results']

    event_count = event_jsons.length
    while event_count > 1
      puts "Fetching more results... (#{event_count} results from last request)"
      start_milis = event_jsons.last['time'].to_i

      result_jsons = get_api_response_for('/2/events', {
        group_id: group_id,
        time: "#{start_milis},",
        status: 'past'
      })['results']

      all_event_ids = Set.new(event_jsons.map { |hsh| hsh["id"] })
      fetched_event_ids = Set.new(result_jsons.map { |hsh| hsh["id"] })
      break if fetched_event_ids.proper_subset?(all_event_ids)

      event_jsons += result_jsons
      event_count = result_jsons.count
    end

    ap event_jsons.map { |hsh| hsh.slice('id', 'name', 'description', 'event_url') }, plain: true
  end

  def associate_user bridgetroll_user, meetup_id
    raise "User already associated with #{bridgetroll_user.meetup_id}" if bridgetroll_user.meetup_id.present?

    meetup_user = MeetupUser.where(meetup_id: meetup_id).first
    Rsvp.transaction do
      if meetup_user.present?
        Rsvp.where(user_type: 'MeetupUser', user_id: meetup_user.id).find_each do |rsvp|
          rsvp.user = bridgetroll_user
          rsvp.save!
        end
      end

      bridgetroll_user.meetup_id = meetup_id
      bridgetroll_user.save!
    end
  end

  def disassociate_user bridgetroll_user
    raise "User is not associated with a meetup account!" unless bridgetroll_user.meetup_id.present?

    meetup_user = MeetupUser.where(meetup_id: bridgetroll_user.meetup_id).first
    Rsvp.transaction do
      Rsvp.where(user_type: 'User', user_id: bridgetroll_user.id).find_each do |rsvp|
        rsvp.user = meetup_user
        rsvp.save!
      end

      bridgetroll_user.meetup_id = nil
      bridgetroll_user.save!
    end
  end

  private

  def find_user(meetup_id)
    meetup_user = MeetupUser.where(meetup_id: meetup_id).first_or_initialize

    associated_user = User.find_by_meetup_id(meetup_id)
    if associated_user.present?
      return associated_user
    else
      return meetup_user
    end
  end

  def create_or_update_rsvp(user, event, role)
    existing_rsvp = event.rsvps.where(user_id: user.id, user_type: user.class.name).first
    if existing_rsvp.present?
      existing_rsvp.update_attribute(:role, Role::ORGANIZER) if role == Role::ORGANIZER
    else
      event.rsvps.create!({user: user, role: role}, without_protection: true)
    end
  end

  def remove_rsvp(user, event, role)
    rsvps = event.rsvps.where(user_id: user.id, user_type: user.class.name, role_id: role.id)
    if rsvps.present?
      unless Rails.env.test?
        puts "Destroying #{rsvps.count} RSVPs for #{user.full_name} (#{user.class.name})"
      end
      rsvps.destroy_all
    end
  end

  def get_api_response_for path, params=nil
    params ||= {}
    params[:key] = ENV['MEETUP_API_KEY']
    params[:sign] = true
    url = "https://api.meetup.com#{path}?#{params.to_param}"

    sleep 1 unless Rails.env.test?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.get(uri.request_uri)

    return false unless assert_valid_status(url, resp)

    json = JSON.parse(resp.body)
    assert_valid_response(url, json) ? json : false
  end

  def import_venue venue_json, chapter_name
    chapter = Chapter.where(name: chapter_name).first_or_create!

    location = Location.where(name: venue_json['name']).first_or_initialize
    location.chapter = chapter
    location_attributes = venue_json.slice('address_1', 'address_2', 'city', 'state', 'zip').reject { |_, v| v.length > 100 }

    location.update_attributes(location_attributes.inject({}) { |hsh, (k, v)| hsh[k] = v.strip; hsh })
    location
  end
end