class EventList
  UPCOMING = 'upcoming'.freeze,
  PAST = 'past'.freeze,
  ALL = 'all'.freeze,

  def initialize(type = UPCOMING)
    @type = type
  end

  def as_json(options = {})
    combined_events.sort_by { |e| e.starts_at.to_time }.as_json
  end

  def combined_events
    bridgetroll_events.includes(:location, :event_sessions, :organizers, :legacy_organizers) + external_events
  end

  private

  def bridgetroll_events
    if @type == PAST
      Event.past.published
    elsif @type == ALL
      Event.published
    else
      Event.upcoming.published
    end
  end

  def external_events
    if @type == PAST
      ExternalEvent.past
    elsif @type == ALL
      ExternalEvent.all
    else
      ExternalEvent.upcoming
    end
  end
end