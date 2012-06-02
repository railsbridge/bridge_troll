# == Schema Information
# Schema version: 20120410060636
#
# Table name: events
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  date        :datetime
#  location_id :integer
#

class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteer_rsvps, :foreign_key => "event_id"
  has_many :volunteers, :through => :volunteer_rsvps, :source => :user
  validates_presence_of :title
  validates_presence_of :date
  
    
  def rsvp_for_user(user)
    self.volunteer_rsvps.find_by_user_id(user.id)
  end
  
  def volunteering?(user)
    self.volunteer_rsvps.find{|r| r.user_id == user.id && r.attending}.present?
  end
  
  scope :upcoming, lambda { where('date >= ?', Time.now.utc.beginning_of_day) }
end
