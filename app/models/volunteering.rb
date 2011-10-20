class Volunteering < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_uniqueness_of :user_id, :scope => [:event_id], :message => "is already volunteering for this event"
end
