class RsvpMailer < BaseMailer
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def confirmation(rsvp)
    if rsvp.waitlisted?
      email(rsvp,  "You're on the waitlist for #{rsvp.event.title}!")
    else
      email(rsvp,  "You've signed up for #{rsvp.event.title}!")
    end
  end

  def reminder(rsvp)
    email(rsvp, "Reminder: You've signed up for #{rsvp.event.title}")
  end

  def reminder_for_session(rsvp_session)
    rsvp = rsvp_session.rsvp
    email(rsvp, "Reminder: You've signed up for #{rsvp_session.event_session.name} at #{rsvp.event.title}")
  end

  def off_waitlist(rsvp)
    @rsvp = rsvp
    mail(
      to: rsvp.user.email,
      subject: "You're confirmed for #{rsvp.event.title}"
    )
  end

  def childcare_notification(rsvp)
    @rsvp = rsvp
    set_recipients(rsvp.event.organizers.map(&:email))

    mail(
      subject: "Childcare request for #{rsvp.event.title}",
      template_name: 'childcare_notification'
    )
  end

  private

  def email(rsvp, subject)
    @rsvp = rsvp
    mail(
      to: rsvp.user.email,
      subject: subject,
      template_name: 'email'
    )
  end
end
