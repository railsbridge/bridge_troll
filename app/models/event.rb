class Event < ActiveRecord::Base
  CLASS_LEVEL_UNKNOWN = 0
  CLASS_LEVEL_BASIC = 1
  CLASS_LEVEL_INTERMEDIATE = 2
  CLASS_LEVEL_ADVANCED = 3
  CLASS_LEVELS = [CLASS_LEVEL_UNKNOWN, CLASS_LEVEL_BASIC, CLASS_LEVEL_INTERMEDIATE, CLASS_LEVEL_ADVANCED]

  belongs_to :location
  has_many :registrations

  has_many :volunteers, :through => :volunteerings, :source => "user"
  has_many :volunteerings

  has_many :users, :through => :registrations, :order => "created_at asc"

  validates :name, :presence => true
  validates :location_id, :presence => true, :numericality => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  validates :capacity, :numericality => { :greater_than_or_equal_to => 0 }
  validates :guests_per_user, :numericality => { :greater_than_or_equal_to => 0 }

  scope :upcoming, where("end_time > ?", Time.now).order(:start_time)
  scope :past, where("end_time <= ?", Time.now).order(:start_time).reverse_order

  def registered_users
    users[0,capacity]
  end

  def waitlisted_users
    users[capacity,users.count]
  end 

  def full?
    registrations.active.size >= capacity
  end

  def to_s
    name
  end

  def self.from_form(params)
    params[:start_time] = DateTime.parse(params[:start_time])
    params[:end_time] = DateTime.parse(params[:end_time])
    return params
  end
end
