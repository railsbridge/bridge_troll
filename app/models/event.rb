class Event < ActiveRecord::Base
  belongs_to :location
  has_many :registrations
  
  validates :name, :presence => true
  validates :location_id, :presence => true, :numericality => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :capacity, :numericality => { :greater_than_or_equal_to => 0 }
  validates :guests_per_user, :numericality => { :greater_than_or_equal_to => 0 }
  
  
  def full?
    registrations.active >= capacity
  end
  
  
end
