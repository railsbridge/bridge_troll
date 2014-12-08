class RsvpSession < ActiveRecord::Base
  belongs_to :rsvp
  belongs_to :event_session

  validates_uniqueness_of :rsvp_id, scope: :event_session_id
  validates_presence_of :event_session
  validates_presence_of :rsvp

  after_save :update_counter_cache
  after_destroy :update_counter_cache

  def user_full_name
    rsvp.user.full_name
  end

  def update_counter_cache
    rsvp.checkins_count = rsvp.rsvp_sessions.where('rsvp_sessions.checked_in = ?', true).count
    rsvp.save
  end

  def as_json(options = {})
    super.merge(role_id: rsvp.role_id)
  end
end
