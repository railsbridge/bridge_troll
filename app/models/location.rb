class Location < ActiveRecord::Base
  has_many :events
  validates_presence_of :name, :address_1, :city
  acts_as_gmappable(process_geocoding: !Rails.env.test?)

  def gmaps4rails_address
    "#{self.address_1}, #{self.city}, #{self.state}, #{self.zip}"
  end

  def as_json(options = {})
    {
      name: name,
      address_1: address_1,
      address_2: address_2,
      city: city,
      state: state,
      zip: zip,
      latitude: latitude,
      longitude: longitude,
    }
  end
end