class Event < ActiveRecord::Base
  after_initialize :set_defaults

  belongs_to :location
  
  has_many :rsvps, dependent: :destroy

  has_many :student_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::STUDENT.id }
  has_many :students, through: :student_rsvps, source: :user, source_type: 'User'
  has_many :legacy_students, through: :student_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :volunteer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::VOLUNTEER.id }
  has_many :volunteers, through: :volunteer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_volunteers, through: :volunteer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :organizer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::ORGANIZER.id }
  has_many :organizers, through: :organizer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_organizers, through: :organizer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :event_sessions, dependent: :destroy
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

  def rsvps_with_childcare
    student_rsvps.needs_childcare
  end

  def historical?
    meetup_volunteer_event_id || meetup_student_event_id
  end

  def ordered_volunteer_rsvps
    bridgetroll_rsvps = volunteer_rsvps.where(user_type: 'User').includes(:bridgetroll_user).order('checkins_count > 0 DESC, lower(users.first_name) ASC, lower(users.last_name) ASC')
    if historical?
      bridgetroll_rsvps + volunteer_rsvps.where(user_type: 'MeetupUser').includes(:meetup_user).order('lower(meetup_users.full_name) ASC')
    else
      bridgetroll_rsvps
    end
  end

  def self.upcoming
    includes(:event_sessions).where('event_sessions.ends_at > ?', Time.now.utc)
  end

  def self.past
    includes(:event_sessions).where('event_sessions.ends_at < ?', Time.now.utc)
  end

  def upcoming?
    ends_at > Time.now
  end

  def volunteers_with_legacy
    volunteers + legacy_volunteers
  end

  def organizers_with_legacy
    organizers + legacy_organizers
  end

  def rsvp_for_user(user)
    self.rsvps.find_by_user_id(user.id)
  end

  def no_rsvp?(user)
    !rsvps.where(user_id: user.id).any?
  end

  def student?(user)
    student_rsvps.where(user_id: user.id).any?
  end

  def volunteer?(user)
    volunteer_rsvps.where(user_id: user.id).any?
  end

  def organizer?(user)
    organizer_rsvps.where(user_id: user.id).any?
  end

  private

  def set_defaults
    self.details ||= Event::DEFAULT_DETAILS
  end

  DEFAULT_DETAILS = <<-END
<h2>Workshop Description</h2>

<h2>Location and Sponsors</h2>

<h2>Transportation and Parking</h2>

<h2>Food and Drinks</h2>

<h2>Childcare</h2>

<h2>Afterparty</h2>
  END
end
