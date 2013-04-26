class RsvpMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def send_confirmation(rsvp)
    if rsvp.role == Role::VOLUNTEER
      volunteer_email(rsvp,  'Thanks for volunteering with Railsbridge!')
    end
  end

  def volunteer_reminder(rsvp)
    volunteer_email(rsvp, "Reminder: You're volunteering with Railsbridge")
  end

  private

  def volunteer_email(rsvp, subject)
    @rsvp = rsvp
    mail(
      to: rsvp.user.email, subject: subject,
      template_name: 'confirm_volunteer'
    )
  end
end
