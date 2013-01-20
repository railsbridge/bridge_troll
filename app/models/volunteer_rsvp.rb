class VolunteerRsvp < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, scope: :event_id
  validates_presence_of :user, :event
end
