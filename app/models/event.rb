class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteerRsvps
  has_many :users, :through => :volunteerRsvps
  validates_presence_of :title
  validates_presence_of :date
end
