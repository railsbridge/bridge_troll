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

  def import
    return unless assert_key_exists

    MEETUP_EVENTS.each_with_index do |event_data, index|
      puts "Importing event #{index+1} of #{MEETUP_EVENTS.length}"
      import_student_and_volunteer_event(event_data)
    end
  end

  def import_student_and_volunteer_event event_data
    event = import_event(
      name: event_data[:name],
      event_id: event_data[:volunteer_event_id],
      finder_key: :meetup_volunteer_event_id,
      rsvp_role_id: Role::VOLUNTEER
    )
    import_event(
      name: event_data[:name],
      event_id: event_data[:student_event_id],
      event: event,
      finder_key: :meetup_student_event_id,
      rsvp_role_id: Role::STUDENT
    )
  end

  def import_event options
    event_json = get_api_response_for("/2/event/#{options[:event_id]}")
    return unless event_json

    location = import_venue(event_json['venue'])

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

    import_rsvps(event, options[:finder_key], options[:rsvp_role_id])

    event
  end

  def import_rsvps event, finder_key, rsvp_role_id
    event_id = event.send(finder_key)
    rsvp_json = get_api_response_for('/2/rsvps', {
      event_id: event_id,
      fields: 'host'
    })
    return unless rsvp_json

    rsvp_json['results'].each do |rsvp|
      next if rsvp['response'] == 'no'

      meetup_id = rsvp['member']['member_id']
      role_id = rsvp['host'] ? Role::ORGANIZER : rsvp_role_id

      meetup_user = MeetupUser.where(meetup_id: meetup_id).first_or_initialize
      meetup_user.update_attributes(full_name: rsvp['member']['name'])

      existing_rsvp = event.rsvps.where(user_id: meetup_user.id, user_type: 'MeetupUser').first
      if existing_rsvp.present?
        existing_rsvp.update_attribute(:role_id, Role::ORGANIZER) if role_id == Role::ORGANIZER
      else
        event.rsvps.create!(user: meetup_user, role_id: role_id)
      end
    end
  end

  def dump_events
    start_milis = DateTime.parse('2009-06-01').to_i * 1000
    puts "Fetching first set of results..."
    event_jsons = get_api_response_for('/2/events', {
      group_id: 134063,
      time: "#{start_milis},",
      status: 'past'
    })['results']

    event_count = event_jsons.length
    while event_count > 1
      puts "Fetching more results... (#{event_count} results from last request)"
      start_milis = event_jsons.last['time'].to_i
      result_jsons = get_api_response_for('/2/events', {
        group_id: 134063,
        time: "#{start_milis},",
        status: 'past'
      })['results']

      event_jsons += result_jsons
      event_count = result_jsons.count
    end

    ap event_jsons.map { |hsh| hsh.slice('id', 'name', 'description', 'event_url') }, plain: true
  end

  private

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

  def import_venue venue_json
    location = Location.where(name: venue_json['name']).first_or_initialize
    location_attributes = venue_json.slice('address_1', 'address_2', 'city', 'state', 'zip').reject { |_, v| v.length > 100 }

    location.update_attributes(location_attributes.inject({}) { |hsh, (k, v)| hsh[k] = v.strip; hsh })
    location
  end
end