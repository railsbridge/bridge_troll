class Location < ActiveRecord::Base
  has_many :events
  validates_presence_of :name, :address_1, :city
  acts_as_gmappable

  def gmaps4rails_address
    "#{self.address_1}, #{self.city}, #{self.state}, #{self.zip}" 
  end
end