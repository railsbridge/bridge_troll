class EventSession < ActiveRecord::Base
  include PresenceTrackingBoolean

  PERMITTED_ATTRIBUTES = [:starts_at, :ends_at, :name, :required_for_students, :volunteers_only, :location_overridden, :location_id]

  belongs_to :location, required: false

  validates_presence_of :starts_at, :ends_at, :name
  validates_uniqueness_of :name, scope: [:event_id]
  validate on: :create do
    if starts_at && starts_at < Time.now
      errors.add(:starts_at, 'must start in the future') unless event && event.historical?
    end
  end
  validate do
    if starts_at && ends_at && ends_at < starts_at
      errors.add(:ends_at, 'must be after session start time')
    end
  end
  validate do
    if required_for_students && volunteers_only
      errors.add(:base, "A session cannot be both Required for Students and Volunteers Only")
    end
  end

  belongs_to :event, inverse_of: :event_sessions
  has_many :rsvp_sessions, dependent: :destroy
  has_many :rsvps, through: :rsvp_sessions

  after_save :update_event_times
  after_destroy :update_event_times

  after_save :update_counter_cache
  after_destroy :update_counter_cache

  add_presence_tracking_boolean(:location_overridden, :location_id)

  def true_location
    location || event.location
  end

  def update_event_times
    return unless event

    # TODO: This 'reload' shouldn't be needed, but without it, the
    # following minimum/maximum statements return 'nil' when
    # initially creating an event and its session. Booo!
    event.reload
    event.update_attributes(
      starts_at: event.event_sessions.minimum("event_sessions.starts_at"),
      ends_at: event.event_sessions.maximum("event_sessions.ends_at")
    )
  end

  def starts_at
    (event && event.persisted?) ? date_in_time_zone(:starts_at) : read_attribute(:starts_at)
  end

  def ends_at
    (event && event.persisted?) ? date_in_time_zone(:ends_at) : read_attribute(:ends_at)
  end

  def session_date
    (starts_at ? starts_at : Date.current).strftime('%Y-%m-%d')
  end

  def date_in_time_zone start_or_end
    read_attribute(start_or_end).in_time_zone(ActiveSupport::TimeZone.new(event.time_zone))
  end

  def has_rsvps?
    persisted? && rsvps.count > 0
  end

  def update_counter_cache
    location.try(:reset_events_count)
    if location_id_changed? && location_id_was
      Location.find(location_id_was).reset_events_count
    end
  end
end
