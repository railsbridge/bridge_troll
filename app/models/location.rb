class Location < ActiveRecord::Base
  has_many :events
  validates_presence_of :name, :address
end
