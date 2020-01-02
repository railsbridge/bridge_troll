# frozen_string_literal: true

require 'rails_helper'

describe RsvpSession do
  context 'checkins counter cache' do
    let(:rsvp) { create(:rsvp) }
    let!(:session1) { rsvp.rsvp_sessions.first }
    let!(:session2) { create(:rsvp_session, rsvp: rsvp) }

    it 'counts the number of checkins' do
      expect(rsvp.checkins_count).to eq(0)

      expect do
        session1.checked_in = true
        session1.save!
      end.to change { rsvp.reload.checkins_count }.by(1)

      expect do
        session2.checked_in = true
        session2.save!
      end.to change { rsvp.reload.checkins_count }.by(1)

      expect do
        session1.destroy
      end.to change { rsvp.reload.checkins_count }.by(-1)
    end
  end
end
