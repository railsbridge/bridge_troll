class EventList
  UPCOMING = 'upcoming'.freeze,
  PAST = 'past'.freeze,
  ALL = 'all'.freeze,

  def initialize(type = UPCOMING, options = {})
    @type = type
    @options = options
  end

  def as_json(options = {})
    combined_events.sort_by { |e| e.starts_at.to_time }.as_json
  end

  def combined_events
    apply_options(bridgetroll_events).includes(:location, :event_sessions, :organizers, :legacy_organizers) + apply_options(external_events)
  end

  def apply_options(scope)
    if @options[:organization_id]
      scope.joins(chapter: :organization).where('organizations.id = ?', @options[:organization_id])
    else
      scope
    end
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