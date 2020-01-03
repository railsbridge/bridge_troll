# frozen_string_literal: true

class EventList
  UPCOMING = 'upcoming'
  PAST = 'past'
  ALL = 'all'

  def initialize(type = UPCOMING, options = {})
    @type = type
    @options = options
  end

  def as_json(_options = {})
    if @options[:serialization_format] == 'dataTables'
      datatables_json
    else
      all_sorted_events.as_json
    end
  end

  def to_csv
    EventCsvReporter.new(all_sorted_events).to_csv
  end

  private

  def all_sorted_events
    (bridgetroll_events.includes(:location, :event_sessions, :organizers, :legacy_organizers, :organization) + external_events.includes(:organization))
      .sort_by(&:starts_at)
  end

  def apply_options(scope)
    if @options[:organization_id]
      scope.joins(chapter: :organization).where('organizations.id = ?', @options[:organization_id])
    else
      scope
    end
  end

  def datatables_json
    query = @options[:search].try(:[], 'value')
    event_ids_and_dates =
      query_cols(BRIDGE_TROLL_COLS, bridgetroll_events.select(:id, :starts_at).joins(:location), query) +
      query_cols(EXTERNAL_COLS, external_events.select(:id, :starts_at), query)
    event_ids_by_type = event_ids_and_dates
                        .sort_by(&:starts_at).reverse
                        .slice(@options[:start].to_i, @options[:length].to_i)
                        .each_with_object({}) do |event, hsh|
      hsh[event.class.name] ||= []
      hsh[event.class.name] << event.id
    end

    all_events =
      Event.includes(:location).where(id: event_ids_by_type['Event']) +
      ExternalEvent.where(id: event_ids_by_type['ExternalEvent'])
    data = all_events.sort_by(&:starts_at).reverse.map do |event|
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

  def bridgetroll_events
    apply_options(
      case @type
      when PAST
        Event.past.published
      when ALL
        Event.published
      else
        Event.upcoming.published
      end
    )
  end

  def external_events
    apply_options(
      case @type
      when PAST
        ExternalEvent.past
      when ALL
        ExternalEvent.all
      else
        ExternalEvent.upcoming
      end
    )
  end

  BRIDGE_TROLL_COLS = %w[title locations.name locations.city].freeze
  EXTERNAL_COLS = %w[name location].freeze

  def query_cols(columns, relation, query)
    return relation unless query

    clauses = columns.map { |f| "(LOWER(#{f}) LIKE #{like_clause})" }.join(' OR ')
    args = [clauses] + Array.new(columns.length) { query }
    relation.where(*args)
  end

  def like_clause
    Rails.application.using_postgres? ? "CONCAT('%', LOWER(?), '%')" : "'%' || LOWER(?) || '%'"
  end
end
