class Event < ActiveRecord::Base
  CLASS_LEVEL_UNKNOWN = 0
  CLASS_LEVEL_BASIC = 1
  CLASS_LEVEL_INTERMEDIATE = 2
  CLASS_LEVEL_ADVANCED = 3
  CLASS_LEVELS = [CLASS_LEVEL_UNKNOWN, CLASS_LEVEL_BASIC, CLASS_LEVEL_INTERMEDIATE, CLASS_LEVEL_ADVANCED]

  belongs_to :location
  has_many :registrations

  validates :name, :presence => true
  validates :location_id, :presence => true, :numericality => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :capacity, :numericality => { :greater_than_or_equal_to => 0 }
  validates :guests_per_user, :numericality => { :greater_than_or_equal_to => 0 }

  def full?
    registrations.active.size >= capacity
  end
end
