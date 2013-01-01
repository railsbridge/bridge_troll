class EventOrganizer < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  validates_presence_of :event_id, :user_id

  validates_uniqueness_of :user_id, :scope => :event_id

  belongs_to :event
  belongs_to :user

  def self.organizer?(event_id, user_id)
    !where("event_id = ? and user_id =?", event_id, user_id).blank?
  end

end
