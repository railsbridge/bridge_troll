class EventList
  UPCOMING = 'upcoming'.freeze,
  PAST = 'past'.freeze,
  ALL = 'all'.freeze,
  def initialize(type = UPCOMING, options = {})
    @type = type
    @options = options
  end

  def as_json(options = {})
    if @options[:serialization_format] == 'dataTables'
      datatables_json
    else
      all_sorted_events.as_json
    end
  end

  def to_csv
    EventCsvReporter.new(all_sorted_events).to_csv
  end

  def all_sorted_events
    all_events = bridgetroll_events.includes(*default_bridgetroll_event_includes).includes(:organization) + external_events.includes(:organization)
    all_events.sort_by { |e| e.starts_at.to_time }
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

  def datatables_json
    query = @options[:search].try(:[], 'value')
    event_ids_and_dates =
      bt_search(bridgetroll_events.select(:id, :starts_at).joins(:location), query) +
        external_search(external_events.select(:id, :starts_at), query)
    event_ids_by_type = event_ids_and_dates
                          .sort_by { |e| e.starts_at.to_time }
                          .reverse
                          .slice(@options[:start].to_i, @options[:length].to_i)
                          .each_with_object({}) do |event, hsh|
      hsh[event.class.name] ||= []
      hsh[event.class.name] << event.id
    end

    all_events =
      Event.includes(:location).where(id: event_ids_by_type['Event']) +
        ExternalEvent.where(id: event_ids_by_type['ExternalEvent'])
    data = all_events.sort_by { |e| e.starts_at.to_time }.reverse.map do |event|
      {
        title: event.title,
        global_id: event.to_global_id.to_s,
        url: event.is_a?(Event) ? "/events/#{event.id}" : event.to_linkable,
        location_name: event.location_name,
        location_city_and_state: event.location_city_and_state,
        imported_event_data: event.imported_event_data,
        date: I18n.localize(event.date_in_time_zone(:starts_at), format: :date_as_day_mdy)
      }
    end

    {
      draw: @options[:draw],
      recordsTotal: event_ids_and_dates.length,
      recordsFiltered: event_ids_and_dates.length,
      data: data
    }
  end

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

  def bt_search(relation, query)
    return relation unless query

    clauses = ["title", "locations.name", "locations.city"].map do |f|
      "(#{like_clause(f)})"
    end.join(' OR ')
    relation.where(clauses, query, query, query)
  end

  def external_search(relation, query)
    return relation unless query

    clauses = ["name", "location"].map do |f|
      "(#{like_clause(f)})"
    end.join(' OR ')
    relation.where(clauses, query, query)
  end

  def like_clause(field)
    if using_postgres
      "LOWER(#{field}) LIKE CONCAT('%', LOWER(?), '%')"
    else
      "LOWER(#{field}) LIKE '%' || LOWER(?) || '%'"
    end
  end

  def using_postgres
    @using_postgres ||= (ActiveRecord::Base.connection.adapter_name == "PostgreSQL")
  end
end