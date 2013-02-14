class Event < ActiveRecord::Base
  belongs_to :location
  
  has_many :rsvps

  has_many :volunteer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::VOLUNTEER }
  has_many :volunteers, through: :volunteer_rsvps, source: :user
  has_many :organizer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::ORGANIZER }
  has_many :organizers, through: :organizer_rsvps, source: :user

  has_many :event_sessions  
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

  def self.upcoming
    includes(:event_sessions).where('event_sessions.ends_at > ?', Time.now.utc)
  end

  def rsvp_for_user(user)
    self.rsvps.find_by_user_id(user.id)
  end
  
  def volunteer?(user)
    volunteer_rsvps.where(user_id: user.id).any?
  end

  def organizer?(user)
    organizer_rsvps.where(user_id: user.id).any?
  end
end
