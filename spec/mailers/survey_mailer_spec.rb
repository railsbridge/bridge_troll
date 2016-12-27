require 'rails_helper'

describe SurveyMailer do
  let(:rsvp) { create(:rsvp) }
  let(:user) { rsvp.user }
  let(:event) { rsvp.event }
  let(:mail) { SurveyMailer.notification(rsvp) }

  describe "the survey email" do
    it_behaves_like 'a mailer view'

    it "is sent to the RSVP'd person" do
      expect(mail.to).to eq([user.email])
    end

    it "includes the survey link" do
      expect(mail.subject).to eq "How was #{event.title}?"
      expect(mail.body).to include "Click right here to take the survey!"
      expect(mail.body).to include "Test greeting"
    end
  end
end
