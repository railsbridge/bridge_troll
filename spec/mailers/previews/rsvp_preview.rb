class RsvpPreview < ActionMailer::Preview
  def confirmation
    RsvpMailer.confirmation(Rsvp.first)
  end

  def reminder
    RsvpMailer.reminder(Rsvp.first)
  end

  def reminder_for_session
    RsvpMailer.reminder_for_session(RsvpSession.first)
  end

  def off_waitlist
    RsvpMailer.off_waitlist(Rsvp.first)
  end

end
