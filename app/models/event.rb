class Event < ActiveRecord::Base
  after_initialize :set_defaults
  after_save :reorder_waitlist!

  belongs_to :location
  
  has_many :rsvps, dependent: :destroy

  has_many :student_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::STUDENT.id, waitlist_position: nil }
  has_many :student_waitlist_rsvps, class_name: 'Rsvp', conditions: "role_id == #{Role::STUDENT.id} AND waitlist_position IS NOT NULL"
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

  validate :validate_rsvp_limit

  with_options(if: Proc.new {|event| !event.historical? }) do |non_historical_event|
    non_historical_event.validates_numericality_of :student_rsvp_limit, only_integer: true, greater_than: 0
  end

  def rsvps_with_childcare
    rsvps.needs_childcare
  end

  def historical?
    meetup_volunteer_event_id || meetup_student_event_id
  end

  def at_limit?
    student_rsvps.count >= student_rsvp_limit
  end

  def validate_rsvp_limit
    if student_rsvp_limit_was.is_a?(Integer) && student_rsvp_limit < student_rsvp_limit_was
      errors.add(:student_rsvp_limit, "can't be decreased")
      false
    end
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

  def reorder_waitlist!
    return if historical?

    Rsvp.transaction do
      unless at_limit?
        number_of_open_spots = student_rsvp_limit - student_rsvps.count
        to_be_confirmed = student_waitlist_rsvps.order(:waitlist_position).limit(number_of_open_spots)
        to_be_confirmed.each do |rsvp|
          rsvp.promote_from_waitlist!
        end
      end

      index = 1
      student_waitlist_rsvps.order(:waitlist_position).find_each do |rsvp|
        rsvp.update_attribute(:waitlist_position, index)
        index += 1
      end
    end
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
