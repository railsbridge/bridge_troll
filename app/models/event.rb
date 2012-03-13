class Event < ActiveRecord::Base
  belongs_to :location
  has_many :volunteerRsvps
  has_many :users, :through => :volunteerRsvps
end
