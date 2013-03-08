class Rsvp < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :bridgetroll_user, class_name: 'User', foreign_key: :user_id
  belongs_to :user, polymorphic: true
  belongs_to :event
  has_many :rsvp_sessions, dependent: :destroy

  validates_uniqueness_of :user_id, scope: :event_id
  validates_presence_of :user, :event, :role

  MAX_EXPERIENCE_LENGTH = 250
  with_options(if: Proc.new {|rsvp| rsvp.role_id == Role::VOLUNTEER && rsvp.user_type == 'User' }) do |for_volunteers|
    for_volunteers.validates_presence_of :teaching_experience, :subject_experience
    for_volunteers.validates_length_of :teaching_experience, :subject_experience, :in => 10..MAX_EXPERIENCE_LENGTH
  end
  
  belongs_to_active_hash :role
  belongs_to_active_hash :volunteer_assignment

  def formatted_preference
    if teaching
      if taing
        'Teaching or TAing'
      else
        'Teaching'
      end
    elsif taing
      'TAing'
    else
      'No Preference'
    end
  end

  def set_attending_sessions session_ids
    rsvp_sessions.destroy_all
    session_ids.each do |session_id|
      rsvp_sessions.create(event_session_id: session_id)
    end
  end
end
