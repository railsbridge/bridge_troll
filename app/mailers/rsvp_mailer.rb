class RsvpMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def confirmation(rsvp)
    email(rsvp,  "You've signed up for #{rsvp.event.title}!")
  end

  def reminder(rsvp)
    email(rsvp, "Reminder: You're volunteering at #{rsvp.event.title}")
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
