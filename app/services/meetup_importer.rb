require 'net/http'
require 'meetups'

class MeetupImporter
  def sanitize str
    str.encode('UTF-16', undef: :replace, invalid: :replace, :replace => '').encode('UTF-8')
  end

  def assert_key_exists
    return true if ENV['MEETUP_API_KEY']

    puts <<MESSAGE
No API key found!

Find your Meetup account's API key at http://www.meetup.com/meetup_api/key/
then add it to your .env file as MEETUP_API_KEY=your_api_key_goes_here
MESSAGE
    return false
  end

  def assert_valid_response url, response
    return true unless response['problem']

    puts <<MESSAGE
---------------
The meetup API request had some sort of error:
url: #{url}

#{response['problem']}
#{response['details']}
---------------
MESSAGE
    return false
  end

  def import
    assert_key_exists

    Event.where('meetup_volunteer_event_id IS NOT NULL').find_each do |event|
      event.destroy
    end

    MEETUP_EVENTS.each do |event|
      import_event event
    end
  end

  def import_event event_hash
    id = event_hash[:volunteer_event_id]
    url = "https://api.meetup.com/2/event/#{id}?key=#{ENV['MEETUP_API_KEY']}&sign=true"
    resp = get_https_response_for(url)

    event_json = JSON.parse(resp.body)

    return unless assert_valid_response(url, event_json)

    location = create_or_update_location_from_venue(event_json['venue'])

    event = Event.new(
        title: event_hash[:name],
        details: sanitize(event_json['description']),
        time_zone: 'Pacific Time (US & Canada)',
        location: location,
        meetup_volunteer_event_id: id
    )
    event_start = Time.at(event_json['time'].to_i / 1000)
    event.event_sessions << EventSession.new(name: 'Installfest + Workshop', starts_at: event_start, ends_at: event_start + 1.day)
    event.save!
  end

  def dump_events
    start_milis = DateTime.parse('2009-06-01').to_i * 1000
    puts "Fetching first set of results..."
    url = "https://api.meetup.com/2/events?key=#{ENV['MEETUP_API_KEY']}&sign=true&group_id=134063&time=#{start_milis},&status=past"
    resp = get_https_response_for(url)

    event_jsons = JSON.parse(resp.body)['results']

    event_count = event_jsons.length
    while event_count > 1
      puts "Fetching more results... (#{event_count} results from last request)"
      start_milis = JSON.parse(resp.body)['results'].last['time'].to_i
      url = "https://api.meetup.com/2/events?key=#{ENV['MEETUP_API_KEY']}&sign=true&group_id=134063&time=#{start_milis},&status=past"
      resp = get_https_response_for(url)

      result_jsons = JSON.parse(resp.body)['results']
      event_jsons += result_jsons
      event_count = result_jsons.count
    end

    ap event_jsons.map { |hsh| hsh.slice('id', 'name', 'description', 'event_url') }, plain: true
  end

  def get_https_response_for url
    sleep 1 unless Rails.env.test?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri)
  end

  private

  def create_or_update_location_from_venue venue_json
    location = Location.where(name: venue_json['name']).first_or_initialize
    location_attributes = venue_json.slice('address_1', 'address_2', 'city', 'state', 'zip').reject { |_,v| v.length > 100 }

    location.update_attributes(location_attributes.inject({}) { |hsh, (k, v)| hsh[k] = v.strip; hsh })
    location.save!
    location
  end
end