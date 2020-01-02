# frozen_string_literal: true

class SurveyPreview < ActionMailer::Preview
  def notification
    SurveyMailer.notification(Rsvp.first)
  end
end
