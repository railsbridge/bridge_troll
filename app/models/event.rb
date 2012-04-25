class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteerRsvps
  has_many :users, :through => :volunteerRsvps
  validates_presence_of :title
  validates_presence_of :date
  
  def ymd
	self.date.strftime('%-m/%e/%Y')
  end
  def hm
	self.date.strftime('%l:%M %P')
  end
end
