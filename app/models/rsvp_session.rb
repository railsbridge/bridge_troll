class RsvpSession < ActiveRecord::Base
  belongs_to :rsvp
  belongs_to :event_session

  validates_uniqueness_of :rsvp_id, scope: :event_session_id

  def user_full_name
    rsvp.user.full_name
  end
end
