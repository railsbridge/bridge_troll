require 'rails_helper'

RSpec.describe PastEventEmailsPresenter do
  subject(:presenter) { PastEventEmailsPresenter.new(event) }
  let(:event) { FactoryGirl.create(:event) }
  let!(:event_emails) { FactoryGirl.create_list(:event_email, 2, event: event) }
  let!(:event_emails_recipients) do
    volunteer_rsvp = FactoryGirl.create(:volunteer_rsvp, event: event)
    student_rsvp = FactoryGirl.create(:student_rsvp, event: event)
    event_emails.first.recipient_rsvps << [volunteer_rsvp, student_rsvp]
  end

  describe '#emails' do
    it 'presents past event emails' do
      emails = presenter.emails
      expect(emails).to match_array(event_emails)
      expect(emails.last.created_at).to be > emails.first.created_at
    end
  end

  describe '#recipient_counts' do
    it 'presents an object listing recipient counts by total and type' do
      expect(presenter.recipient_counts.length).to eq 2
      expect(presenter.recipient_counts).to eq({
        event_emails.last.id => { total: 0, volunteers: 0, students: 0 },
        event_emails.first.id => { total: 2, volunteers: 1, students: 1 }
      })
    end
  end
end
