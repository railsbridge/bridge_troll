class Location < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:name, :address_1, :address_2, :city, :state, :zip, :region_id]

  scope :available, -> { where(archived_at: nil) }
  has_many :events
  belongs_to :region, counter_cache: true
  has_many :event_sessions

  validates_presence_of :name, :address_1, :city, :region
  unless Rails.env.test?
    geocoded_by :full_address
    after_validation :geocode
  end

  def full_address
    "#{address_1}, #{city}, #{state}, #{zip}"
  end

  def name_with_region
    "#{name} (#{region.name})"
  end

  def organized_event?(user)
    notable_events.map { |e| e.organizer?(user) }.include?(true)
  end

  def notable_events
    if events.published.present?
      events.published
    else
      Event.where(location_id: id).where(current_state: Event.current_states.values_at(:draft, :pending_approval))
    end
  end

  def archive!
    update_columns(archived_at: DateTime.now)
  end

  def archived?
    archived_at.present?
  end

  def all_events
    Event.where(id: events.pluck(:id) + event_sessions.pluck(:event_id))
  end

  def as_json(options = {})
    {
      name: name,
      address_1: address_1,
      address_2: address_2,
      city: city,
      state: state,
      zip: zip,
      latitude: latitude,
      longitude: longitude,
    }
  end

  def most_recent_event_date
    relevant_events = (events + event_sessions.map(&:event)).compact
    if relevant_events.present?
      event = relevant_events.sort_by(&:starts_at).last
      event.starts_at.in_time_zone(event.time_zone).strftime("%b %d, %Y")
    else
      "No events found."
    end
  end

  def inferred_time_zone
    return nil unless latitude && longitude
    NearestTimeZone.to(latitude, longitude)
  end

  def reset_events_count
    update_column(:events_count, all_events.count)
  end
end
