class SurveySender
  def self.send_surveys(event)
    attendee_rsvps = event.attendee_rsvps
    attendee_rsvps.each do |rsvp|
      SurveyMailer.notification(rsvp).deliver
    end
  end
end
