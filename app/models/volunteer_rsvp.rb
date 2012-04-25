# == Schema Information
# Schema version: 20120410060636
#
# Table name: volunteer_rsvps
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  event_id   :integer
#  attending  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class VolunteerRsvp < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, :scope => :event_id
end
