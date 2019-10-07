class Rsvp < ActiveRecord::Base
  include PresenceTrackingBoolean

  belongs_to :bridgetroll_user, class_name: 'User', foreign_key: :user_id, optional: true
  belongs_to :meetup_user, class_name: 'MeetupUser', foreign_key: :user_id, optional: true
  belongs_to :user, polymorphic: true
  belongs_to :event, inverse_of: :rsvps
  belongs_to :section, optional: true

  delegate :full_name, to: :user
  delegate :historical?, to: :event, allow_nil: true

  has_many :rsvp_sessions, dependent: :destroy
  has_many :event_sessions, through: :rsvp_sessions
  has_many :dietary_restrictions, dependent: :destroy
  has_many :event_email_recipients, foreign_key: :recipient_rsvp_id, dependent: :destroy

  has_one  :survey, dependent: :destroy

  validates_uniqueness_of :user_id, scope: [:event_id, :user_type]
  validates_presence_of :role
  validates_presence_of :childcare_info, if: :needs_childcare?

  scope :confirmed, -> { where("waitlist_position IS NULL") }
  scope :checked_in, -> { where.not(checkins_count: 0) }
  scope :needs_childcare, -> { where("childcare_info <> ''") }

  after_initialize :set_defaults

  after_save :update_counter_cache
  after_destroy :update_counter_cache

  MAX_EXPERIENCE_LENGTH = 250
  with_options(unless: :historical?) do |normal_event|
    normal_event.with_options(if: :role_volunteer?) do |for_volunteers|
      for_volunteers.validates_presence_of :subject_experience
      for_volunteers.validates_length_of :subject_experience, in: 10..MAX_EXPERIENCE_LENGTH
    end

    normal_event.with_options(if: :teaching_or_taing?) do |for_teachers|
      for_teachers.validates_presence_of :class_level
      for_teachers.validates_inclusion_of :class_level, in: (0..5), allow_blank: true
      for_teachers.validates_presence_of :teaching_experience
      for_teachers.validates_length_of :teaching_experience, in: 10..MAX_EXPERIENCE_LENGTH
    end

    normal_event.with_options(if: :role_student?) do |for_students|
      for_students.validates_presence_of :operating_system_id, :class_level
      for_students.validates_inclusion_of :class_level, in: (1..5), allow_blank: true
    end

    normal_event.with_options(if: :requires_session_rsvp?) do |attendee_rsvp|
      attendee_rsvp.validates :rsvp_sessions, length: { minimum: 1, message: 'must be selected' }
    end
  end

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :role
  belongs_to_active_hash :volunteer_assignment
  belongs_to_active_hash :operating_system
  belongs_to_active_hash :volunteer_preference

  add_presence_tracking_boolean(:needs_childcare, :childcare_info)

  def set_defaults
    if has_attribute?(:token)
      self.token ||= SecureRandom.uuid.delete('-')
    end
  end

  # Dispatch to the two possible types of user, the modern kind (User) or imports
  # from meetup (MeetupUser). This is mostly important for weird eager loading
  # situations like Event#ordered_rsvps
  #
  # Ideally eager loading would work better for polymorphic associations, so the
  # regular 'user' association could be used instead of this. But it doesn't!
  # This can probably be removed if this Rails PR ever gets accepted:
  # https://github.com/rails/rails/pull/17479
  def loaded_user
    user_type == 'MeetupUser' ? meetup_user : bridgetroll_user
  end

  def setup_for_role(role)
    self.role = role
    if role == Role::VOLUNTEER
      self.event_session_ids = event.event_sessions.pluck(:id)
    elsif role == Role::STUDENT
      self.event_session_ids = event.event_sessions.where(required_for_students: true).pluck(:id)
    end

    return unless user

    last_rsvp = find_last_relevant_rsvp(user, event)
    if last_rsvp
      assign_attributes(last_rsvp.carryover_attributes(event.course, role))
    end
  end

  def selectable_sessions
    sessions = event.event_sessions.order('starts_at ASC')
    if role == Role::VOLUNTEER
      sessions
    elsif role == Role::STUDENT
      sessions.where(volunteers_only: false)
    else
      raise "No selectable_sessions for Role::#{role.name}"
    end
  end

  def level_title
    level.title if role == Role::STUDENT
  end

  def level
    event.levels.find {|level| level.num == class_level}
  end

  def operating_system_title
    operating_system.try(:title)
  end

  def operating_system_type
    operating_system.try(:type)
  end

  def full_dietary_info
    restrictions = dietary_restrictions.map { |dr| dr.restriction.capitalize }
    restrictions << dietary_info if dietary_info.present?
    restrictions.join(', ')
  end

  def dietary_restriction_diets
    dietary_restrictions.map(&:restriction)
  end

  def dietary_restriction_diets=(diets)
    self.dietary_restrictions = diets.map do |diet|
      DietaryRestriction.new(restriction: diet)
    end
  end

  def no_show?
    return false if event.historical?
    return false if event.upcoming?

    checkins_count == 0
  end

  def checked_in_session_ids
    if role == Role::ORGANIZER
      event.event_sessions.map(&:id)
    else
      rsvp_sessions.where(checked_in: true).pluck(:event_session_id)
    end
  end

  def role_volunteer?
    role == Role::VOLUNTEER
  end

  def role_student?
    role == Role::STUDENT
  end

  def teaching_or_taing?
    teaching || taing
  end

  def requires_session_rsvp?
    return false if role == Role::ORGANIZER
    event.try(:upcoming?)
  end

  def volunteer_preference_id
    return unless role_volunteer?

    return VolunteerPreference::BOTH.id    if teaching && taing
    return VolunteerPreference::TEACHER.id if teaching
    return VolunteerPreference::TA.id      if taing
    VolunteerPreference::NEITHER.id
  end

  def carryover_attributes(course, role)
    fields = [:job_details]
    if role == Role::VOLUNTEER && event.course == course
      fields += [:subject_experience, :teaching_experience]
    end

    fields.each_with_object({}) do |field, hsh|
      hsh[field] = send(field)
    end
  end

  def formatted_preference
    volunteer_preference.title
  end

  def waitlisted?
    !!waitlist_position
  end

  def update_counter_cache
    event&.update_rsvp_counts
  end

  def as_json(options={})
    options[:methods] ||= []
    options[:methods] |= [:full_name, :operating_system_title, :operating_system_type, :level_title]
    super(options)
  end

  private

  def find_last_relevant_rsvp(user, event)
    prior_rsvps = user.rsvps.includes(:event).order('events.ends_at')
    if event.course
      prior_rsvps.where('events.course_id = ?', event.course.id).last || prior_rsvps.last
    else
      prior_rsvps.last
    end
  end
end
