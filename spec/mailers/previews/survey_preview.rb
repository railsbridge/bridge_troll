class SurveyPreview < ActionMailer::Preview
  def notification
    SurveyMailer.notification(Rsvp.first)
  end
end
