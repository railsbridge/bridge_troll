require 'rails_helper'

RSpec.describe EventEmailPresenter do
  subject(:presenter) { EventEmailPresenter.new(event_email) }
  let(:event_email) { FactoryBot.create(:event_email, event: event) }

  let(:event) { FactoryBot.create(:event) }
  let!(:volunteer_rsvp) { FactoryBot.create(:volunteer_rsvp, event: event) }
  let!(:student_accepted_rsvp) { FactoryBot.create(:student_rsvp, event: event) }
  let!(:student_waitlisted_rsvp) { FactoryBot.create(:student_rsvp, event: event, waitlist_position: 1) }

  describe '#rsvps' do
    it 'presents the rsvps for the event' do
      expect(presenter.rsvps).to match_array([volunteer_rsvp, student_accepted_rsvp, student_waitlisted_rsvp])
    end
  end

  describe '#volunteers_rsvps' do
    it 'presents the rsvps for the event volunteers' do
      expect(presenter.volunteers_rsvps).to match_array([volunteer_rsvp])
    end
  end

  describe '#students_accepted_rsvps' do
    it 'presents the rsvps for the event students who were accepted' do
      expect(presenter.students_accepted_rsvps).to match_array([student_accepted_rsvp])
    end
  end

  describe '#students_waitlisted_rsvps' do
    it 'presents the rsvps for the event students who were waitlisted' do
      expect(presenter.students_waitlisted_rsvps).to match_array([student_waitlisted_rsvp])
    end
  end
end
