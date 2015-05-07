require 'rails_helper'

describe SurveySender do
  describe ".send_surveys" do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    before do
      event_session = event.event_sessions.first

      create(:volunteer_rsvp, event: event, session_checkins: {event_session.id => true})

      create(:student_rsvp, event: event, session_checkins: {event_session.id => true})

      create(:volunteer_rsvp, event: event, session_checkins: {event_session.id => false})
    end

    it "sends survey emails to all the attendees who checked in" do
      expect {
        SurveySender.send_surveys(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end

    it "updates survey_sent_at to the current time" do
      expect {
        SurveySender.send_surveys(event)
      }.to change { event.reload.survey_sent_at }
    end
  end
end
