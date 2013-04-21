class RsvpMailer < ActionMailer::Base
  add_template_helper(EventsHelper)
  add_template_helper(LocationsHelper)

  def confirm(rsvp)
    @rsvp = rsvp
    @event = rsvp.event
    mail(to: rsvp.user.email, subject: 'Thanks for signing up for a Railsbridge workshop!')
  end
end
