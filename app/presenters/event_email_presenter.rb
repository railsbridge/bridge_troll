class EventEmailPresenter < SimpleDelegator
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
end
