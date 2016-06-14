class Event < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:title, :target_audience, :location_id, :chapter_id, :details, :time_zone, :volunteer_details, :public_email, :starts_at, :ends_at, :student_rsvp_limit, :volunteer_rsvp_limit, :course_id, :allow_student_rsvp, :student_details, :plus_one_host_toggle, :email_on_approval, :has_childcare, :restrict_operating_systems,
  :survey_greeting]
  DEFAULT_CODE_OF_CONDUCT_URL = 'http://bridgefoundry.org/code-of-conduct/'

  serialize :allowed_operating_system_ids, JSON
  serialize :external_event_data, JSON
  enum current_state: [ :draft, :pending_approval, :published ]
  validates :current_state, inclusion: { in: Event.current_states.keys }

  after_initialize :set_defaults
  before_validation :normalize_allowed_operating_system_ids
  after_save do |event|
    if student_rsvp_limit_changed? || volunteer_rsvp_limit_changed?
      WaitlistManager.new(event).reorder_waitlist!
    end
  end

  after_create :update_location_counts
  after_save do
    update_location_counts if location_id_changed?
  end
  after_destroy :update_location_counts

  belongs_to :location
  belongs_to :chapter, counter_cache: true
  has_one :organization, through: :chapter

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :course

  has_one :region, through: :location

  has_many :rsvps, dependent: :destroy, inverse_of: :event
  has_many :sections, dependent: :destroy
  has_many :event_emails, dependent: :destroy

  has_many :attendee_rsvps, -> { where(role_id: Role.attendee_role_ids, waitlist_position: nil) }, class_name: 'Rsvp', inverse_of: :event

  has_many :student_rsvps, -> { where(role_id: Role::STUDENT.id, waitlist_position: nil) }, class_name: 'Rsvp', inverse_of: :event
  has_many :student_waitlist_rsvps, -> { where("role_id = #{Role::STUDENT.id} AND waitlist_position IS NOT NULL").order(:waitlist_position) }, class_name: 'Rsvp', inverse_of: :event
  has_many :students, through: :student_rsvps, source: :user, source_type: 'User'
  has_many :legacy_students, through: :student_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :volunteer_rsvps, -> { where(role_id: Role::VOLUNTEER.id, waitlist_position: nil) }, class_name: 'Rsvp', inverse_of: :event
  has_many :volunteer_waitlist_rsvps, -> { where("role_id = #{Role::VOLUNTEER.id} AND waitlist_position IS NOT NULL").order(:waitlist_position) }, class_name: 'Rsvp', inverse_of: :event
  has_many :volunteers, through: :volunteer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_volunteers, through: :volunteer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :organizer_rsvps, -> { where(role_id: Role::ORGANIZER.id) }, class_name: 'Rsvp', inverse_of: :event
  has_many :organizers, through: :organizer_rsvps, source: :user, source_type: 'User'
  has_many :legacy_organizers, through: :organizer_rsvps, source: :user, source_type: 'MeetupUser'

  has_many :event_sessions, -> { order('ends_at ASC') }, dependent: :destroy, inverse_of: :event
  accepts_nested_attributes_for :event_sessions, allow_destroy: true
  validates :event_sessions, length: { minimum: 1 }

  validates_presence_of :title
  validates_presence_of :time_zone
  validates_presence_of :chapter
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map(&:name), allow_blank: true
  validates :allowed_operating_system_ids, array_of_ids: OperatingSystem.all.map(&:id), if: :restrict_operating_systems?
  validates_presence_of :target_audience, unless: :historical?, if: [:allow_student_rsvp?, :target_audience_required?]

  with_options(unless: :historical?) do |normal_event|
    normal_event.with_options(if: :allow_student_rsvp?) do |workshop_event|
      workshop_event.validates_numericality_of :student_rsvp_limit, greater_than: 0
      workshop_event.validate :validate_student_rsvp_limit
    end

    with_options(if: :has_volunteer_limit?) do |workshop_event|
      workshop_event.validates_numericality_of :volunteer_rsvp_limit, greater_than: 0
      workshop_event.validate :validate_volunteer_rsvp_limit
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

  def has_multiple_locations?
    all_locations.length > 1
  end

  def rsvps_with_childcare
    rsvps.confirmed.needs_childcare
  end

  def has_volunteer_limit?
    volunteer_rsvp_limit != nil
  end

  def historical?
    !!external_event_data
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
    if student_rsvp_limit
      student_rsvps_count >= student_rsvp_limit
    end
  end

  def volunteers_at_limit?
    if volunteer_rsvp_limit
      volunteer_rsvps_count >= volunteer_rsvp_limit
    end
  end

  def survey_sent?
    !!survey_sent_at
  end

  def can_send_announcement_email?
    upcoming? && published? && !email_on_approval && announcement_email_sent_at.nil?
  end

  def validate_student_rsvp_limit
    return unless persisted? && student_rsvp_limit

    if student_rsvp_limit < student_rsvps_count
      errors.add(:student_rsvp_limit, "can't be decreased lower than the number of existing RSVPs (#{student_rsvps.length})")
      false
    end
  end

  def validate_volunteer_rsvp_limit
    return unless persisted? && volunteer_rsvp_limit

    if volunteer_rsvp_limit < volunteer_rsvps_count
      errors.add(:volunteer_rsvp_limit, "can't be decreased lower than the number of existing RSVPs (#{volunteer_rsvps.length})")
      false
    end
  end

  def checked_in_rsvps(role)
    if upcoming? || historical?
      association_for_role(role)
    else
      association_for_role(role).where("checkins_count > 0")
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
        Role::ORGANIZER,
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

  def date_in_time_zone start_or_end
    read_attribute(start_or_end).in_time_zone(ActiveSupport::TimeZone.new(time_zone))
  end

  def upcoming?
    ends_at > Time.now
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
    rsvps.find_by_user_id(user.id)
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
      {name: e.name, starts_at: e.starts_at, ends_at: e.ends_at}
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
      only: [:id, :title, :student_rsvp_limit],
      methods: [:location]
    }.merge(options)
    super(options).merge(
      workshop: !!(allow_student_rsvp || historical?),
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

  def levels
    course[:levels]
  end

  private

  DEFAULT_DETAIL_FILES = Dir[Rails.root.join('app', 'models', 'event_details', '*.html')]
  DEFAULT_DETAILS = DEFAULT_DETAIL_FILES.each_with_object({}) do |f, hsh|
    hsh[File.basename(f)] = File.read(f)
  end

  def set_defaults
    if self.has_attribute?(:details)
      self.details ||= Event::DEFAULT_DETAILS['default_details.html']
      self.student_details ||= Event::DEFAULT_DETAILS['default_student_details.html']
      self.volunteer_details ||= Event::DEFAULT_DETAILS['default_volunteer_details.html']
      self.survey_greeting ||= Event::DEFAULT_DETAILS['default_survey_greeting.html']
      self.allowed_operating_system_ids ||= OperatingSystem.all.map(&:id)
    end
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
    if self.allowed_operating_system_ids.respond_to?(:each)
      self.allowed_operating_system_ids.map! do |id|
        id.try(:match, /\A\d+\z/) ? Integer(id) : id
      end
    end
  end

  def update_location_counts
    location.try(:reset_events_count)
    if location_id_changed? && location_id_was
      Location.find(location_id_was).reset_events_count
    end
  end
end
