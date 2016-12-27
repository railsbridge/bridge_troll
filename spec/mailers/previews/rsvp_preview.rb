class RsvpPreview < ActionMailer::Preview
  def confirmation
    RsvpMailer.confirmation(Rsvp.first)
  end

  def reminder
    RsvpMailer.reminder(Rsvp.first)
  end

  def multiple_location_event_reminder
    rsvp = EventSession.where('location_id IS NOT NULL').all.map do |event_session|
      event_session.rsvps.where(role_id: Role::VOLUNTEER.id).first
    end.compact.first
    RsvpMailer.reminder(rsvp)
  end

  def reminder_for_session
    RsvpMailer.reminder_for_session(RsvpSession.first)
  end

  def off_waitlist
    RsvpMailer.off_waitlist(Rsvp.first)
  end

  def childcare_notification
    RsvpMailer.childcare_notification(Rsvp.first)
  end
end
