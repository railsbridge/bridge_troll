# Generates downloadable calendar event files to support 'Export to iCal' feature
class IcsGenerator
  require 'icalendar'
  require 'date'

  include Icalendar

  def event_session_ics(event_session)
    cal = Calendar.new
    cal.event do
      dtstart   event_session.starts_at.to_datetime
      dtend     event_session.ends_at.to_datetime
      summary   "#{event_session.event.title}: #{event_session.name}"
      location  event_session.event.location_name
    end
    cal.to_ical
  end
end
