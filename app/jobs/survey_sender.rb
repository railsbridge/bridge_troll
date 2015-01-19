class SurveySender
  def self.send_surveys(event)
    attendee_rsvps = event.attendee_rsvps.where('checkins_count > 0')
    attendee_rsvps.each do |rsvp|
      SurveyMailer.notification(rsvp).deliver_now
    end
    event.update_attribute(:survey_sent_at, DateTime.now)
  end
end
