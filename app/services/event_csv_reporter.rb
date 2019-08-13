class EventCsvReporter
  def initialize(events)
    @events = events
  end

  def to_csv
    CSV.generate do |csv|
      csv << fields
      @events.each do |event|
        row_builder = EventCsvRowBuilder.new(event)
        csv << fields.map { |f| row_builder.send(f) }
      end
    end
  end

  private

  def fields
    [
      :region,
      :chapter,
      :city,
      :location,
      :title,
      :url,
      :starts_at,
      :ends_at,
      :organizers,
      :is_workshop,
      :is_imported,
      :is_external,
      :time_zone,
      :attended,
      :waitlisted
    ]
  end

  class EventCsvRowBuilder
    attr_reader :event_json, :event

    def initialize(event)
      @event = event
      @event_json = event.as_json.symbolize_keys
    end

    def region
      event.region.try(:name)
    end

    def chapter
      event.chapter.try(:name)
    end

    def city
      event_json[:location][:city]
    end

    def location
      event_json[:location][:name]
    end

    def title
      event_json[:title]
    end

    def url
      if event.is_a?(Event)
        if event.imported_event_data
          event.imported_event_data['student_event']['url']
        else
          "https://#{ENV['HOST_URL']}/events/#{event.id}"
        end
      else
        event.url
      end
    end

    def starts_at
      return event.starts_at if event.is_a?(ExternalEvent)
      event.starts_at.in_time_zone(event.time_zone).to_date
    end

    def ends_at
      return event.ends_at if event.is_a?(ExternalEvent)
      event.ends_at.in_time_zone(event.time_zone).to_date
    end

    def organizers
      event_json[:organizers].try(:join, ', ')
    end

    def is_workshop
      event_json[:workshop]
    end

    def is_imported
      event.is_a?(Event) && event.historical?
    end

    def is_external
      event.is_a?(ExternalEvent)
    end

    def time_zone
      return nil unless bridgetroll_event?
      event.time_zone
    end

    def attended
      return nil unless bridgetroll_event?
      event.checked_in_rsvps(Role::VOLUNTEER).count + event.checked_in_rsvps(Role::STUDENT).count
    end

    def waitlisted
      return nil unless bridgetroll_event?
      event.volunteer_waitlist_rsvps_count + event.student_waitlist_rsvps_count
    end

    private

    def bridgetroll_event?
      event.is_a?(Event) && !event.historical?
    end
  end
end
