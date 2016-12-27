require 'rails_helper'

describe SurveySender do
  describe ".send_all_surveys" do
    def create_event_for_date(d)
      create(:event).tap do |e|
        e.event_sessions.first.update_attributes(starts_at: d, ends_at: d + 10.seconds)
      end
    end

    it "sends surveys for all past events" do
      very_old_event = create_event_for_date(SurveySender::FIRST_AUTO_SEND_DATE - 5.days)
      already_sent_event = create_event_for_date(2.days.ago)
      already_sent_event.update_attribute(:survey_sent_at, 1.day.ago)
      recent_event = create_event_for_date(3.days.ago)
      upcoming_event = create_event_for_date(25.days.from_now)

      sent_survey_events = []
      expect(SurveySender).to receive(:send_surveys) do |event|
        sent_survey_events << event
      end

      SurveySender.send_all_surveys
      expect(sent_survey_events).to match_array([recent_event])
    end
  end

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

    it "does not send any surveys if the survey has already been sent" do
      SurveySender.send_surveys(event)

      expect {
        SurveySender.send_surveys(event)
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    it "updates survey_sent_at to the current time" do
      expect {
        SurveySender.send_surveys(event)
      }.to change { event.reload.survey_sent_at }
    end
  end
end
