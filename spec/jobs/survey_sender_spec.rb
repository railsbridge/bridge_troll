require 'spec_helper'

describe SurveySender do
  describe ".send_surveys" do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    let!(:rsvp) { create(:volunteer_rsvp, event: event) }
    let!(:student_rsvp) { create(:student_rsvp, event: event) }

    it "sends survey emails to all the attendees" do
      expect {
        SurveySender.send_surveys(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(event.rsvps.count)
    end
  end
end
