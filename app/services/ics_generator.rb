# Generates downloadable calendar event files to support 'Export to iCal' feature
class IcsGenerator
  require 'icalendar'
  require 'date'

  include Icalendar

  def event_session_ics(event_session)
    cal = Calendar.new
    cal.event do |e|
      e.dtstart   = event_session.starts_at.to_datetime
      e.dtend     = event_session.ends_at.to_datetime
      e.summary   = "#{event_session.event.title}: #{event_session.name}"
      e.location  = event_session.true_location.try(:name)
    end
    cal.to_ical
  end
end
