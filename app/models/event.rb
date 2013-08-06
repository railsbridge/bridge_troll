require 'meetups'

class Event < ActiveRecord::Base
  after_initialize :set_defaults
  after_save :reorder_waitlist!

  belongs_to :location

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :course
  
  has_many :rsvps, dependent: :destroy
  has_many :sections, dependent: :destroy

  has_many :attendee_rsvps, class_name: 'Rsvp', conditions: { role_id: [Role::STUDENT.id, Role::VOLUNTEER.id], waitlist_position: nil }

  has_many :student_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::STUDENT.id, waitlist_position: nil }
  has_many :student_waitlist_rsvps, class_name: 'Rsvp', conditions: "role_id = #{Role::STUDENT.id} AND waitlist_position IS NOT NULL"
  has_many :students, through: :student_rsvps, source: :user, source_type: 'User'
  has_many :legacy_students, through: :student_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :volunteer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::VOLUNTEER.id }
  has_many :volunteers, through: :volunteer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_volunteers, through: :volunteer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :organizer_rsvps, class_name: 'Rsvp', conditions: { role_id: Role::ORGANIZER.id }
  has_many :organizers, through: :organizer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_organizers, through: :organizer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :event_sessions, dependent: :destroy, order: 'ends_at ASC'
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

  with_options(if: Proc.new {|event| !event.historical? }) do |non_historical_event|
    non_historical_event.validates_numericality_of :student_rsvp_limit, only_integer: true, greater_than: 0
    non_historical_event.validate :validate_rsvp_limit
  end

  def rsvps_with_childcare
    rsvps.needs_childcare
  end

  def historical?
    meetup_volunteer_event_id || meetup_student_event_id
  end

  def meetup_url meetup_event_id
    return nil unless historical?

    meetup_group_url = MeetupEventInfo.url_for_event(meetup_event_id)
    "http://#{meetup_group_url}/events/#{meetup_event_id}/"
  end

  def at_limit?
    if student_rsvp_limit
      student_rsvps.count >= student_rsvp_limit
    end
  end

  def validate_rsvp_limit
    if student_rsvp_limit_was.is_a?(Integer) && student_rsvp_limit < student_rsvp_limit_was
      errors.add(:student_rsvp_limit, "can't be decreased")
      false
    end
  end

  def checked_in_student_rsvps
    checked_in_rsvps(student_rsvps)
  end

  def checked_in_volunteer_rsvps
    checked_in_rsvps(volunteer_rsvps)
  end

  def checked_in_rsvps(assoc)
    if upcoming? || historical?
      assoc
    else
      assoc.where("checkins_count > 0")
    end
  end

  def checkin_counts
    counts = {
      rsvp: {},
      checkin: {}
    }

    event_sessions.each do |session|
      counts[:rsvp][session.id] = session.rsvp_sessions.count
      counts[:checkin][session.id] = session.rsvp_sessions.where(checked_in: true).count
    end

    counts
  end

  def ordered_student_rsvps
    ordered_rsvps(student_rsvps)
  end

  def ordered_volunteer_rsvps
    ordered_rsvps(volunteer_rsvps)
  end

  def ordered_rsvps(assoc)
    bridgetroll_rsvps = assoc.where(user_type: 'User').includes(:bridgetroll_user).order('checkins_count > 0 DESC, lower(users.first_name) ASC, lower(users.last_name) ASC')
    if historical?
      bridgetroll_rsvps + assoc.where(user_type: 'MeetupUser').includes(:meetup_user).order('lower(meetup_users.full_name) ASC')
    else
      bridgetroll_rsvps
    end
  end

  def attendee_rsvps_with_workshop_checkins
    rsvp_jsons = attendee_rsvps.includes(:user).as_json
    workshop_checkins = RsvpSession.where(event_session_id: event_sessions.last.id, checked_in: true).map(&:rsvp_id)
    rsvp_jsons.each do |rsvp_json|
      rsvp_id = rsvp_json['id']
      rsvp_json['workshop_checkins_count'] = workshop_checkins.include?(rsvp_id) ? 1 : 0
    end
  end

  def self.upcoming
    where('ends_at > ?', Time.now.utc).order('starts_at')
  end

  def self.past
    where('ends_at < ?', Time.now.utc)
  end

  def date_in_time_zone start_or_end
    read_attribute(start_or_end).in_time_zone(ActiveSupport::TimeZone.new(time_zone))
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

  def waitlisted_student?(user)
    student_waitlist_rsvps.where(user_id: user.id).any?
  end

  def volunteer?(user)
    volunteer_rsvps.where(user_id: user.id).any?
  end

  def organizer?(user)
    organizer_rsvps.where(user_id: user.id).any?
  end

  def checkiner?(user)
    return true if organizer?(user)
    rsvps.where(user_id: user.id, checkiner: true).any?
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

  def dietary_restrictions_totals
    diets = self.rsvps.includes(:dietary_restrictions).map(&:dietary_restrictions).flatten
    restrictions = diets.group_by(&:restriction)
    restrictions.map { |name, diet| restrictions[name] = diet.length }
    restrictions
  end

  def other_dietary_restrictions
    self.rsvps.map { |rsvp| rsvp.dietary_info if rsvp.dietary_info.present? }.compact
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
