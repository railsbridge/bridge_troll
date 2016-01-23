class EventList
  UPCOMING = 'upcoming'.freeze,
  PAST = 'past'.freeze,
  ALL = 'all'.freeze,

  def initialize(type = UPCOMING, options = {})
    @type = type
    @options = options
  end

  def as_json(options = {})
    all_events = bridgetroll_events.includes(*default_bridgetroll_event_includes).includes(:organization) + external_events.includes(:organization)
    all_events.sort_by { |e| e.starts_at.to_time }.as_json
  end

  def combined_events
    bridgetroll_events.includes(*default_bridgetroll_event_includes) + external_events
  end

  def apply_options(scope)
    if @options[:organization_id]
      scope.joins(chapter: :organization).where('organizations.id = ?', @options[:organization_id])
    else
      scope
    end
  end

  private

  def default_bridgetroll_event_includes
    [:location, :event_sessions, :organizers, :legacy_organizers]
  end

  def bridgetroll_events
    relation = if @type == PAST
      Event.past.published
    elsif @type == ALL
      Event.published
    else
      Event.upcoming.published
    end

    apply_options(relation)
  end

  def external_events
    relation = if @type == PAST
      ExternalEvent.past
    elsif @type == ALL
      ExternalEvent.all
    else
      ExternalEvent.upcoming
    end

    apply_options(relation)
  end
end