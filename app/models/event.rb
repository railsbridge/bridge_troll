class Event < ActiveRecord::Base
  belongs_to :location
  
  has_many :rsvps
  has_many :volunteers, through: :rsvps, source: :user
  has_many :event_organizers
  has_many :organizers, through: :event_organizers, source: :user

  has_many :event_sessions  
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_inclusion_of :time_zone,
                         in: ActiveSupport::TimeZone.all.map(&:name),
                         if: lambda { |event| event.time_zone.present? }

  def self.upcoming
    includes(:event_sessions).where('event_sessions.ends_at > ?', Time.now.utc)
  end

  def rsvp_for_user(user)
    self.rsvps.find_by_user_id(user.id)
  end
  
  def volunteering?(user)
    self.rsvps.where(:user_id => user.id, :role_id => Role::VOLUNTEER_ROLE_IDS).any?
  end

  def organizer?(user)
    self.organizers.find { |organizer| organizer == user }.present?
  end
end
