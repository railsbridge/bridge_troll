# frozen_string_literal: true

class Event < ApplicationRecord
  DEFAULT_CODE_OF_CONDUCT_URL = 'http://bridgefoundry.org/code-of-conduct/'

  serialize :allowed_operating_system_ids, JSON
  serialize :imported_event_data, JSON
  enum current_state: { draft: 0, pending_approval: 1, published: 2 }

  after_initialize :set_defaults
  before_validation :normalize_allowed_operating_system_ids
  after_save do |event|
    if saved_change_to_attribute?(:student_rsvp_limit) || saved_change_to_attribute?(:volunteer_rsvp_limit)
      WaitlistManager.new(event).reorder_waitlist!
    end
  end

  after_create :update_location_counts
  after_save do
    update_location_counts if saved_change_to_attribute?(:location_id)
  end
  after_destroy :update_location_counts

  belongs_to :location, optional: true
  belongs_to :chapter, counter_cache: true
  has_one :organization, through: :chapter

  belongs_to :course, optional: true

  has_one :region, through: :location

  has_many :rsvps, dependent: :destroy, inverse_of: :event
  has_many :sections, dependent: :destroy
  has_many :event_emails, dependent: :destroy

  with_options(class_name: 'Rsvp', inverse_of: :event) do
    has_many :attendee_rsvps, lambda {
      where(role_id: Role.attendee_role_ids, waitlist_position: nil)
    }
    has_many :student_rsvps, lambda {
      where(role_id: Role::STUDENT.id, waitlist_position: nil)
    }
    has_many :volunteer_rsvps, lambda {
      where(role_id: Role::VOLUNTEER.id, waitlist_position: nil)
    }
    has_many :student_waitlist_rsvps, lambda {
      where(role_id: Role::STUDENT.id).where.not(waitlist_position: nil).order(:waitlist_position)
    }
    has_many :volunteer_waitlist_rsvps, lambda {
      where(role_id: Role::VOLUNTEER.id).where.not(waitlist_position: nil).order(:waitlist_position)
    }
    has_many :organizer_rsvps, lambda {
      where(role_id: Role::ORGANIZER.id)
    }
  end

  with_options(source: :user, source_type: 'User') do
    has_many :students, through: :student_rsvps
    has_many :volunteers, through: :volunteer_rsvps
    has_many :organizers, through: :organizer_rsvps
  end

  with_options(source: :user, source_type: 'MeetupUser') do
    has_many :legacy_students, through: :student_rsvps
    has_many :legacy_volunteers, through: :volunteer_rsvps
    has_many :legacy_organizers, through: :organizer_rsvps
  end

  has_many :event_sessions, -> { order('ends_at ASC') }, dependent: :destroy, inverse_of: :event
  accepts_nested_attributes_for :event_sessions, allow_destroy: true

  with_options(through: :rsvps, source: :survey) do
    has_many :surveys
    has_many :student_surveys, -> { where('rsvps.role_id = ?', Role::STUDENT.id) }
    has_many :volunteer_surveys, -> { where('rsvps.role_id = ?', Role::VOLUNTEER.id) }
  end

  validates :title, presence: true
  validates :food_provided, inclusion: { in: [true, false] }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true }, presence: true
  validates :current_state, inclusion: { in: Event.current_states.keys }
  validates :event_sessions, length: { minimum: 1 }

  with_options(if: :restrict_operating_systems?) do
    validates :allowed_operating_system_ids, array_of_ids: OperatingSystem.all.map(&:id)
  end

  with_options(unless: :historical?) do
    with_options(if: :allow_student_rsvp?) do
      validates :student_rsvp_limit, numericality: { greater_than: 0 }
      validate :validate_student_rsvp_limit
    end

    with_options(if: %i[allow_student_rsvp? target_audience_required?]) do
      validates :target_audience, presence: true
    end

    with_options(if: :volunteer_limit?) do
      validates :volunteer_rsvp_limit, numericality: { greater_than: 0 }
      validate :validate_volunteer_rsvp_limit
    end
  end

  def target_audience_required?
    new_record? || target_audience_was
  end

  def location_name
    location ? location.name : ''
  end

  def location_city_and_state
    "#{location.city}, #{location.state}"
  end

  def all_locations
    @all_locations ||= ([location] + event_sessions.map(&:location)).compact
  end

  def multiple_locations?
    all_locations.length > 1
  end

  def rsvps_with_childcare
    rsvps.confirmed.needs_childcare
  end

  def volunteer_limit?
    volunteer_rsvp_limit != nil
  end

  def historical?
    !!imported_event_data
  end

  def close_rsvps
    self.open = false
    save
  end

  def reopen_rsvps
    self.open = true
    save
  end

  def closed?
    !open?
  end

  def students_at_limit?
    student_rsvps_count >= student_rsvp_limit if student_rsvp_limit
  end

  def volunteers_at_limit?
    volunteer_rsvps_count >= volunteer_rsvp_limit if volunteer_rsvp_limit
  end

  def survey_sent?
    !!survey_sent_at
  end

  def can_send_announcement_email?
    upcoming? && published? && !email_on_approval && announcement_email_sent_at.nil?
  end

  def validate_student_rsvp_limit
    return unless persisted? && student_rsvp_limit
    return unless student_rsvp_limit < student_rsvps_count

    errors.add(:student_rsvp_limit, "can't be decreased lower than the number of existing RSVPs (#{student_rsvps.length})")
    false
  end

  def validate_volunteer_rsvp_limit
    return unless persisted? && volunteer_rsvp_limit
    return unless volunteer_rsvp_limit < volunteer_rsvps_count

    errors.add(:volunteer_rsvp_limit, "can't be decreased lower than the number of existing RSVPs (#{volunteer_rsvps.length})")
    false
  end

  def checked_in_rsvps(role)
    if upcoming? || historical?
      association_for_role(role)
    else
      association_for_role(role).where('checkins_count > 0')
    end
  end

  def ordered_rsvps(role, waitlisted: false)
    RsvpSorter.new(self, association_for_role(role, waitlisted: waitlisted)).ordered
  end

  def checkin_counts
    counts = Role.attendee_role_ids.each_with_object({}) do |role_id, hsh|
      hsh[role_id] = {
        rsvp: {},
        checkin: {}
      }
    end

    event_sessions.each do |session|
      non_waitlisted_rsvps = session.rsvp_sessions.includes(:rsvp).where('rsvps.waitlist_position IS NULL').references(:rsvps)
      Role.attendee_role_ids.each do |role_id|
        role_rsvps = non_waitlisted_rsvps.where('rsvps.role_id = ?', role_id)
        counts[role_id][:rsvp][session.id] = role_rsvps.count
        counts[role_id][:checkin][session.id] = role_rsvps.where(checked_in: true).count
      end
    end

    counts
  end

  def rsvps_with_checkins
    attendee_rsvps = rsvps
                     .where('waitlist_position IS NULL OR checkins_count > 0')
                     .includes(:user, :rsvp_sessions)
    attendee_rsvps.map do |rsvp|
      rsvp.as_json(methods: [:checked_in_session_ids])
    end
  end

  def self.drafted_by(user)
    # Technically, only one user is the drafter, but we'll mean by this any user who has been
    # associated as an organizer.
    joins(:organizers).where('users.id = ? and current_state = ?', user.id, Event.current_states[:draft])
  end

  def self.published_or_visible_to(user = nil)
    return published unless user

    if user.admin?
      where(spam: false)
    else
      includes(:rsvps).where(
        '(rsvps.role_id = ? AND rsvps.user_id = ?) OR (current_state = ?) OR (chapter_id IN (?))',
        Role::ORGANIZER.id,
        user.id,
        Event.current_states[:published],
        user.chapter_leaderships.pluck(:chapter_id)
      ).references('rsvps')
    end
  end

  def self.upcoming
    where('events.ends_at > ?', Time.now.utc).order('events.starts_at')
  end

  def self.past
    where('events.ends_at < ?', Time.now.utc)
  end

  def date_in_time_zone(start_or_end)
    self[start_or_end].in_time_zone(ActiveSupport::TimeZone.new(time_zone))
  end

  def upcoming?
    ends_at > Time.zone.now
  end

  def past?
    !upcoming?
  end

  def volunteers_with_legacy
    volunteers + legacy_volunteers
  end

  def organizers_with_legacy
    organizers + legacy_organizers
  end

  def rsvp_for_user(user)
    rsvps.find_by(user_id: user.id)
  end

  def no_rsvp?(user)
    user.event_role(self).blank?
  end

  def student?(user)
    user.event_role(self) == Role::STUDENT
  end

  def waitlisted_student?(user)
    student?(user) && user.event_attendances[id][:waitlist_position].present?
  end

  def volunteer?(user)
    user.event_role(self) == Role::VOLUNTEER
  end

  def waitlisted_volunteer?(user)
    volunteer?(user) && user.event_attendances[id][:waitlist_position].present?
  end

  def attendee?(user)
    student?(user) || volunteer?(user)
  end

  def organizer?(user)
    user.event_role(self) == Role::ORGANIZER
  end

  def checkiner?(user)
    return true if organizer?(user)

    user.admin? || user.event_checkiner?(self)
  end

  def dietary_restrictions_totals
    total_dietary_restrictions_for(rsvps.confirmed)
  end

  def checked_in_attendees_dietary_restrictions_totals
    total_dietary_restrictions_for(rsvps.checked_in)
  end

  def total_dietary_restrictions_for(rsvps)
    diets = rsvps.includes(:dietary_restrictions).map(&:dietary_restrictions).flatten
    restrictions = diets.group_by(&:restriction)
    restrictions.each { |name, diet| restrictions[name] = diet.length }
    restrictions
  end

  def other_dietary_restrictions
    other_dietary_restrictions_for(rsvps.confirmed)
  end

  def checked_in_attendees_other_dietary_restrictions
    other_dietary_restrictions_for(rsvps.checked_in)
  end

  def other_dietary_restrictions_for(rsvps)
    rsvps.map { |rsvp| rsvp.dietary_info.presence }.compact
  end

  def organizer_names
    organizers_with_legacy.map(&:full_name)
  end

  def session_details
    event_sessions.map do |e|
      { name: e.name, starts_at: e.starts_at, ends_at: e.ends_at }
    end
  end

  def allowed_operating_systems
    return OperatingSystem.all unless restrict_operating_systems

    OperatingSystem.all.select { |os| allowed_operating_system_ids.include?(os.id) }
  end

  def code_of_conduct_url
    chapter.try(:code_of_conduct_url) || DEFAULT_CODE_OF_CONDUCT_URL
  end

  def update_rsvp_counts
    update_columns(
      volunteer_rsvps_count: volunteer_rsvps.count,
      volunteer_waitlist_rsvps_count: volunteer_waitlist_rsvps.count,
      student_rsvps_count: student_rsvps.count,
      student_waitlist_rsvps_count: student_waitlist_rsvps.count
    )
  end

  def as_json(options = {})
    options = {
      only: %i[id title student_rsvp_limit imported_event_data],
      includes: [:location]
    }.merge(options)
    super(options).merge(
      workshop: (allow_student_rsvp? || historical?),
      organizers: organizer_names,
      sessions: session_details,
      volunteer_rsvp_count: volunteer_rsvps_count,
      volunteer_waitlist_rsvp_count: volunteer_waitlist_rsvps_count,
      student_rsvp_count: student_rsvps_count,
      student_waitlist_rsvp_count: student_waitlist_rsvps_count,
      organization: organization.name
    )
  end

  def to_linkable
    self
  end

  delegate :levels, to: :course

  def asks_custom_question?
    custom_question.present?
  end

  private

  DEFAULT_DETAIL_FILES = Dir[Rails.root.join('app/models/event_details/*.html')]
  DEFAULT_DETAILS = DEFAULT_DETAIL_FILES.each_with_object({}) do |f, hsh|
    hsh[File.basename(f)] = File.read(f)
  end

  def set_defaults
    return unless has_attribute?(:details)

    self.details ||= Event::DEFAULT_DETAILS['default_details.html']
    self.student_details ||= Event::DEFAULT_DETAILS['default_student_details.html']
    self.volunteer_details ||= Event::DEFAULT_DETAILS['default_volunteer_details.html']
    self.survey_greeting ||= Event::DEFAULT_DETAILS['default_survey_greeting.html']
    self.allowed_operating_system_ids ||= OperatingSystem.all.map(&:id)
  end

  def association_for_role(role, waitlisted: false)
    case role
    when Role::VOLUNTEER
      waitlisted ? volunteer_waitlist_rsvps : volunteer_rsvps
    when Role::STUDENT
      waitlisted ? student_waitlist_rsvps : student_rsvps
    else
      raise "Can't find appropriate association for Role::#{role.name}"
    end
  end

  def normalize_allowed_operating_system_ids
    self.allowed_operating_system_ids = nil unless restrict_operating_systems
    return unless self.allowed_operating_system_ids.respond_to?(:each)

    self.allowed_operating_system_ids.map! do |id|
      id.try(:match, /\A\d+\z/) ? Integer(id) : id
    end
  end

  def update_location_counts
    location.try(:reset_events_count)
    return unless saved_change_to_attribute?(:location_id) && saved_changes[:location_id].first

    Location.find(saved_changes[:location_id].first).reset_events_count
  end
end
