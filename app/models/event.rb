require 'meetups'

class Event < ActiveRecord::Base
  after_initialize :set_defaults
  after_save :reorder_waitlist!

  belongs_to :location, counter_cache: true

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :course

  delegate :chapter, to: :location

  has_many :rsvps, dependent: :destroy, inverse_of: :event
  has_many :sections, dependent: :destroy
  has_many :event_emails, dependent: :destroy

  has_many :attendee_rsvps, class_name: 'Rsvp', inverse_of: :event, conditions: { role_id: [Role::STUDENT.id, Role::VOLUNTEER.id], waitlist_position: nil }

  has_many :student_rsvps, class_name: 'Rsvp', inverse_of: :event, conditions: { role_id: Role::STUDENT.id, waitlist_position: nil }
  has_many :student_waitlist_rsvps, class_name: 'Rsvp', inverse_of: :event, conditions: "role_id = #{Role::STUDENT.id} AND waitlist_position IS NOT NULL"
  has_many :students, through: :student_rsvps, source: :user, source_type: 'User'
  has_many :legacy_students, through: :student_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :volunteer_rsvps, class_name: 'Rsvp', inverse_of: :event, conditions: { role_id: Role::VOLUNTEER.id }
  has_many :volunteers, through: :volunteer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_volunteers, through: :volunteer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :organizer_rsvps, class_name: 'Rsvp', inverse_of: :event, conditions: { role_id: Role::ORGANIZER.id }
  has_many :organizers, through: :organizer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_organizers, through: :organizer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :event_sessions, dependent: :destroy, order: 'event_sessions.ends_at ASC', inverse_of: :event
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true

  with_options(if: Proc.new {|event| !event.historical? }) do |non_historical_event|
    non_historical_event.validates_numericality_of :student_rsvp_limit, only_integer: true, greater_than: 0
    non_historical_event.validate :validate_rsvp_limit
  end

  def location_name
    location ? location.name : ''
  end

  def location_city_and_state
    "#{location.city}, #{location.state}"
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
    if persisted? && student_rsvp_limit < student_rsvps.count
      errors.add(:student_rsvp_limit, "can't be decreased lower than the number of existing RSVPs (#{student_rsvps.length})")
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

  def rsvps_with_checkins
    attendee_rsvps = rsvps.where(waitlist_position: nil).includes(:user, :rsvp_sessions)
    attendee_rsvps.map do |rsvp|
      json = rsvp.as_json
      if rsvp.role == Role::ORGANIZER
        json['checked_in_session_ids'] = event_sessions.map(&:id)
      else
        json['checked_in_session_ids'] = rsvp.rsvp_sessions.where(checked_in: true).pluck(:event_session_id)
      end
      json
    end
  end

  def self.for_json
    includes(:location, :event_sessions, :organizers, :legacy_organizers)
  end

  def self.published
    where(published: true)
  end

  def self.published_or_organized_by(user = nil)
    if user
      if user.admin?
        scoped
      else
        includes(:rsvps).where('(rsvps.role_id = ? AND rsvps.user_id = ?) OR (published = ?)', Role::ORGANIZER, user.id, true)
      end
    else
      self.published
    end
  end

  def self.upcoming
    where('events.ends_at > ?', Time.now.utc).order('events.starts_at')
  end

  def self.past
    where('events.ends_at < ?', Time.now.utc)
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

  def organizer_names
    organizers_with_legacy.map { |org| org.full_name }
  end

  def session_details
    event_sessions.map do |e|
      {name: e.name, starts_at: e.starts_at, ends_at: e.ends_at}
    end
  end

  def as_json(options = {})
    {
      id: id,
      title: title,
      location: location,
      organizers: organizer_names,
      sessions: session_details,
      volunteer_rsvp_count: volunteer_rsvps.count,
      student_rsvp_count: student_rsvps.count,
      student_waitlist_rsvp_count: student_waitlist_rsvps.count,
      student_rsvp_limit: student_rsvp_limit
    }
  end

  private

  def set_defaults
    self.details ||= Event::DEFAULT_DETAILS
    self.student_details ||= Event::DEFAULT_STUDENT_DETAILS
    self.volunteer_details ||= Event::DEFAULT_VOLUNTEER_DETAILS
  end

  DEFAULT_DETAILS = <<-END
<h2>Workshop Description</h2>

<h2>Sponsors</h2>

<h2>Transportation and Parking</h2>

<h2>Food and Drinks</h2>

<h2>Childcare</h2>

<h2>Afterparty</h2>
  END

  DEFAULT_STUDENT_DETAILS = <<-END
All students need to bring their own laptop and powercord.

Since bandwidth is usually at a premium at the Installfest, please download RailsInstaller (for PCs and most Mac installations) or XCode (if you're going that route).

You can find more information on what to download by getting started with the Installfest instructions: http://installfest.railsbridge.org
  END

  DEFAULT_VOLUNTEER_DETAILS = <<-END
Be sure to review the curriculum before the workshop. We have several curricula available at http://docs.railsbridge.org.
  END
end
