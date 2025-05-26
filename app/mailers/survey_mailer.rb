# frozen_string_literal: true

class SurveyMailer < ApplicationMailer
  helper(EventsHelper)
  def notification(rsvp)
    @rsvp = rsvp
    mail(
      to: rsvp.user.email,
      subject: "How was #{rsvp.event.title}?"
    )
  end
end
