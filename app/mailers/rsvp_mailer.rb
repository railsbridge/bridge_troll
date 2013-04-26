class RsvpMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def send_confirmation(rsvp)
    if rsvp.role == Role::VOLUNTEER
      confirm_volunteer(rsvp)
    end
  end

  def confirm_volunteer(rsvp)
    @rsvp = rsvp
    @event = rsvp.event
    mail(
      to: rsvp.user.email, subject: 'Thanks for volunteering with Railsbridge!',
      template_name: 'confirm_volunteer'
    )
  end
end
