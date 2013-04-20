class RsvpMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def confirm_volunteer(rsvp)
    @rsvp = rsvp
    @event = rsvp.event
    mail(to: rsvp.user.email, subject: 'Thanks for volunteering with Railsbridge!')
  end
end
