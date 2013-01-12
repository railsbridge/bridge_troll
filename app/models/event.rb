class Event < ActiveRecord::Base

  belongs_to :location
  
  has_many :volunteer_rsvps, :foreign_key => "event_id"
  has_many :volunteers, :through => :volunteer_rsvps, :source => :user
  has_many :event_organizers
  has_many :organizers, :through => :event_organizers, :source => :user
  has_many :days
  accepts_nested_attributes_for :days, :allow_destroy => true

  validates_presence_of :title

  scope :upcoming, lambda { where('date >= ?', Time.now.utc.beginning_of_day) }

  def rsvp_for_user(user)
    self.volunteer_rsvps.find_by_user_id(user.id)
  end
  
  def volunteering?(user)
    self.volunteer_rsvps.find{|r| r.user_id == user.id && r.attending}.present?
  end

  def organizer?(user)
    self.organizers.find { |organizer| organizer == user }.present?
  end
end
