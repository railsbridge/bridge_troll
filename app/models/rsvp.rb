class Rsvp < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :bridgetroll_user, class_name: 'User', foreign_key: :user_id
  belongs_to :meetup_user, class_name: 'MeetupUser', foreign_key: :user_id
  belongs_to :user, polymorphic: true
  belongs_to :event

  belongs_to_active_hash :volunteer_preference

  delegate :historical?, to: :event, allow_nil: true

  has_many :rsvp_sessions, dependent: :destroy

  validates_uniqueness_of :user_id, scope: [:event_id, :user_type]
  validates_presence_of :user, :event, :role
  validates_presence_of :childcare_info, if: lambda { |rsvp| rsvp.needs_childcare? }

  scope :needs_childcare, where("childcare_info <> ''")

  MAX_EXPERIENCE_LENGTH = 250
  with_options(if: Proc.new {|rsvp| rsvp.role == Role::VOLUNTEER && !rsvp.historical? }) do |for_volunteers|
    for_volunteers.validates_presence_of :teaching_experience, :subject_experience
    for_volunteers.validates_length_of :teaching_experience, :subject_experience, :in => 10..MAX_EXPERIENCE_LENGTH
  end

  with_options(if: Proc.new {|rsvp| rsvp.role == Role::STUDENT && !rsvp.historical? }) do |for_students|
    for_students.validates_presence_of :operating_system_id, :class_level
    for_students.validates_inclusion_of :class_level, in: (1..5)
  end


  belongs_to_active_hash :role
  belongs_to_active_hash :volunteer_assignment
  belongs_to_active_hash :operating_system

  def no_show
    return false if event.historical?
    return false if event.upcoming?

    checkins_count == 0
  end

  def volunteer_preference_id
    return unless role == Role::VOLUNTEER

    return VolunteerPreference::BOTH.id    if teaching && taing
    return VolunteerPreference::TEACHER.id if teaching
    return VolunteerPreference::TA.id      if taing
    VolunteerPreference::NEITHER.id
  end

  def formatted_preference
    volunteer_preference.title
  end

  def set_attending_sessions session_ids=nil
    rsvp_sessions.destroy_all
    if role == Role::STUDENT
      session_ids = event.event_sessions.map(&:id)
    end
    if event.event_sessions.length == 1
      session_ids = [event.event_sessions.first.id]
    end
    session_ids.each do |session_id|
      rsvp_sessions.create(event_session_id: session_id)
    end
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

end
