require 'rails_helper'

describe SurveySender do
  describe ".send_surveys" do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    before do
      session = event.event_sessions.first

      volunteer_rsvp = create(:volunteer_rsvp, event: event)
      create(:rsvp_session, rsvp: volunteer_rsvp, event_session: session, checked_in: true)

      student_rsvp = create(:student_rsvp, event: event)
      create(:rsvp_session, rsvp: student_rsvp, event_session: session, checked_in: true)

      no_show_rsvp = create(:volunteer_rsvp, event: event)
    end

    it "sends survey emails to all the attendees who checked in" do
      expect {
        SurveySender.send_surveys(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end
end
