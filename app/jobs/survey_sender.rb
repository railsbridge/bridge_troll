class SurveySender
  FIRST_AUTO_SEND_DATE = Date.parse('2015-11-15')

  def self.send_all_surveys
    Event.where('ends_at > ?', FIRST_AUTO_SEND_DATE)
      .where('ends_at < ?', 1.day.ago)
      .where('survey_sent_at IS NULL').each do |event|
      send_surveys(event)
    end
  end

  def self.send_surveys(event)
    return if event.survey_sent_at.present?

    attendee_rsvps = event.attendee_rsvps.where('checkins_count > 0')
    attendee_rsvps.each do |rsvp|
      SurveyMailer.notification(rsvp).deliver_now
    end
    event.update_attribute(:survey_sent_at, DateTime.now)
  end
end
