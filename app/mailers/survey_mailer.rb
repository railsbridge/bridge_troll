class SurveyMailer < ActionMailer::Base
  def notification(rsvp)
    @rsvp = rsvp
    mail(
      to: rsvp.user.email,
      subject: "How was #{rsvp.event.title}?",
    )
  end
end
