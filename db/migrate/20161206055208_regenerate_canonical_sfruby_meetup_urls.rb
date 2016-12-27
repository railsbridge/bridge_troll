class RegenerateCanonicalSfrubyMeetupUrls < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    serialize :imported_event_data, JSON
  end

  def change
    # The old format stored was like http://www.sfruby.info/events/13311831/,
    # but those URLs don't work anymore for whatever reason.

    # URLs of the form https://www.meetup.com/sfruby/events/13311831/
    # still work fine.
    meetup_events = Event.where.not(imported_event_data: nil)
      .select { |e| e.imported_event_data['student_event']['url'].match /sfruby/ }
    meetup_events.each do |e|
      imported_event_data = e.imported_event_data
      imported_event_data['volunteer_event']['url'] = "https://www.meetup.com/sfruby/events/#{imported_event_data['volunteer_event']['id']}/"
      imported_event_data['student_event']['url'] = "https://www.meetup.com/sfruby/events/#{imported_event_data['student_event']['id']}/"
      e.update_attribute(:imported_event_data, imported_event_data)
    end
  end
end
