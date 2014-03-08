class Rsvp < ActiveRecord::Base
  attr_accessible :subject_experience, :teaching, :taing, :teaching_experience, :teaching_experience,
                  :childcare_info, :operating_system_id, :job_details, :class_level, :dietary_info,
                  :needs_childcare, :event_session_ids

  belongs_to :bridgetroll_user, class_name: 'User', foreign_key: :user_id
  belongs_to :meetup_user, class_name: 'MeetupUser', foreign_key: :user_id
  belongs_to :user, polymorphic: true
  belongs_to :event, inverse_of: :rsvps
  belongs_to :section

  delegate :full_name, to: :user
  delegate :historical?, to: :event, allow_nil: true

  has_many :rsvp_sessions, dependent: :destroy
  has_many :event_sessions, through: :rsvp_sessions
  has_many :dietary_restrictions, dependent: :destroy
  has_many :event_email_recipients, foreign_key: :recipient_rsvp_id, dependent: :destroy

  has_one  :survey

  validates_uniqueness_of :user_id, scope: [:event_id, :user_type]
  validates_presence_of :user, :event, :role
  validates_presence_of :childcare_info, if: lambda { |rsvp| rsvp.needs_childcare? }

  scope :confirmed, where("waitlist_position IS NULL")
  scope :needs_childcare, where("childcare_info <> ''")

  MAX_EXPERIENCE_LENGTH = 250
  with_options(if: Proc.new {|rsvp| rsvp.role_volunteer? && !rsvp.historical? }) do |for_volunteers|
    for_volunteers.validates_presence_of :subject_experience
    for_volunteers.validates_length_of :subject_experience, :in => 10..MAX_EXPERIENCE_LENGTH
  end

  with_options(if: Proc.new {|rsvp| rsvp.teaching || rsvp.taing  }) do |for_teachers|
    for_teachers.validates_presence_of :class_level
    for_teachers.validates_inclusion_of :class_level, in: (0..5), allow_blank: true
    for_teachers.validates_presence_of :teaching_experience
    for_teachers.validates_length_of :teaching_experience, :in => 10..MAX_EXPERIENCE_LENGTH
  end


  with_options(if: Proc.new {|rsvp| rsvp.role_student? && !rsvp.historical? }) do |for_students|
    for_students.validates_presence_of :operating_system_id, :class_level
    for_students.validates_inclusion_of :class_level, in: (1..5), allow_blank: true
  end

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :role
  belongs_to_active_hash :volunteer_assignment
  belongs_to_active_hash :operating_system
  belongs_to_active_hash :volunteer_preference

  def operating_system_title
    operating_system.try(:title)
  end

  def operating_system_type
    operating_system.try(:type)
  end

  def no_show?
    return false if event.historical?
    return false if event.upcoming?

    checkins_count == 0
  end

  def role_volunteer?
    role == Role::VOLUNTEER
  end

  def role_student?
    role == Role::STUDENT
  end

  def volunteer_preference_id
    return unless role_volunteer?

    return VolunteerPreference::BOTH.id    if teaching && taing
    return VolunteerPreference::TEACHER.id if teaching
    return VolunteerPreference::TA.id      if taing
    VolunteerPreference::NEITHER.id
  end

  def volunteer_carryover_attributes
    [:subject_experience, :teaching_experience, :job_details].inject({}) do |hsh, field|
      hsh[field] = send(field)
      hsh
    end
  end

  def formatted_preference
    volunteer_preference.title
  end

  def waitlisted?
    !!waitlist_position
  end

  def promote_from_waitlist!
    update_attribute(:waitlist_position, nil)
    RsvpMailer.off_waitlist(self).deliver
  end

  def needs_childcare?
    @needs_childcare = childcare_info.present? if @needs_childcare.nil?
    @needs_childcare
  end

  alias_method :needs_childcare, :needs_childcare?

  def needs_childcare= needs_childcare
    needs_childcare = needs_childcare == '1' if needs_childcare.is_a? String

    @needs_childcare = needs_childcare
    self.childcare_info = nil unless needs_childcare
    needs_childcare
  end

  before_save do
    unless needs_childcare?
      self.childcare_info = nil
    end
  end

  def self.attendances_for(user_type)
    attendances = {}
    grouped_rsvps = Rsvp.where(user_type: user_type).select('user_id, role_id, count(*) count').group('role_id, user_id')
    grouped_rsvps.all.each do |rsvp_group|
      attendances[rsvp_group.user_id] ||= Role.empty_attendance.clone
      attendances[rsvp_group.user_id][rsvp_group.role_id] = rsvp_group.count.to_i
    end

    attendances
  end

  def as_json(options={})
    options = {
      methods: [:full_name, :operating_system_title, :operating_system_type]
    }.merge(options)
    super(options)
  end
end
