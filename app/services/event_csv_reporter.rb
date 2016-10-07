class EventCsvReporter
  def initialize(events)
    @events = events
  end

  def to_csv
    CSV.generate do |csv|
      csv << [
        'region',
        'chapter',
        'city',
        'location',
        'title',
        'url',
        'starts_at',
        'ends_at',
        'organizers',
        'is_workshop',
        'is_imported',
        'is_external',
        'time_zone',
        'attended',
        'waitlisted'
      ]
      @events.each do |event|
        event_json = event.as_json.symbolize_keys

        column_data = [
          event.region.try(:name),
          event.chapter.try(:name),
          event_json[:location][:city],
          event_json[:location][:name],
          event_json[:title],
          event_url(event),
          event.starts_at,
          event.ends_at,
          event_json[:organizers].try(:join, ', '),
          event_json[:workshop],
          event.is_a?(Event) && event.historical?,
          event.is_a?(ExternalEvent)
        ]
        if event.is_a?(Event) && !event.historical?
          column_data << event.time_zone
          column_data << event.checked_in_rsvps(Role::VOLUNTEER).count + event.checked_in_rsvps(Role::STUDENT).count
          column_data << event.volunteer_waitlist_rsvps_count + event.student_waitlist_rsvps_count
        end
        csv << column_data
      end
    end
  end

  private

  def event_url(event)
    if event.is_a?(Event)
      if event.external_event_data
        event.external_event_data['student_event']['url']
      else
        "https://#{ENV['CANONICAL_HOST']}/events/#{event.id}"
      end
    else
      event.url
    end
  end
end