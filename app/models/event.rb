class Event < ActiveRecord::Base
  belongs_to :location
  
  has_many :volunteer_rsvps, :foreign_key => "event_id"
  has_many :volunteers, :through => :volunteer_rsvps, :source => :user
  has_many :event_organizers
  has_many :organizers, :through => :event_organizers, :source => :user

  has_many :event_sessions  
  accepts_nested_attributes_for :event_sessions, :allow_destroy => true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title

  def self.upcoming
    includes(:event_sessions).where('event_sessions.ends_at > ?', Time.now.utc)
  end
  
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
