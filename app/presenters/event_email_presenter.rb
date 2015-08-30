class EventEmailPresenter
  attr_reader :event_email

  delegate :model_name, :to_key, :to_model, :persisted?,
    :errors, :attendee_group, :include_waitlisted, :only_checked_in,
    :cc_organizers, :subject, :body, to: :event_email

  def initialize(event_email)
    @event_email = event_email
  end

  def rsvps
    @rsvps ||= event.rsvps.where(role_id: Role.attendee_role_ids).includes(:user)
  end

  def volunteers_rsvps
    rsvps.where(role_id: Role::VOLUNTEER.id)
  end

  def students_accepted_rsvps
    rsvps.where(role_id: Role::STUDENT.id).confirmed
  end

  def students_waitlisted_rsvps
    rsvps.where(role_id: Role::STUDENT.id).where.not("waitlist_position IS NULL")
  end

  def event
    event_email.event
  end
end
