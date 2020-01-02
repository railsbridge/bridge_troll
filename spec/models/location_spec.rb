# frozen_string_literal: true

require 'rails_helper'

describe Location do
  it { is_expected.to have_many(:events) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:address_1) }
  it { is_expected.to validate_presence_of(:city) }

  describe '#archive!' do
    let!(:location) { create(:location) }

    it 'can be archived' do
      location.archive!
      expect(location.archived_at).to be_present
    end
  end

  describe '#archived?' do
    let!(:location) { create(:location) }

    it 'returns returns false on unarchived location' do
      expect(location).not_to be_archived
    end

    it 'returns returns true on unarchived location' do
      location.archive!
      expect(location).to be_archived
    end
  end

  describe '#organized_event?' do
    let(:organizer_rsvp) { create(:organizer_rsvp) }
    let(:event) { organizer_rsvp.event }
    let(:location) { event.location }
    let(:organizer) { organizer_rsvp.user }
    let(:user) { create(:user) }

    it 'returns true for a user that organized an event at this location' do
      expect(location.organized_event?(organizer)).to be true
    end

    it 'returns false for a user that has not organized an event at this location' do
      expect(location.organized_event?(user)).to be false
    end
  end

  describe '#most_recent_event_date' do
    it 'finds the event with the most recent start date and returns that date' do
      this_year = Date.current.year
      my_location = create(:location)
      expected_date = DateTime.new(this_year + 3, 1, 5, 12)
      my_location.events << create(:event, starts_at: expected_date)
      my_location.events << create(:event, starts_at: DateTime.new(this_year + 1, 1, 5, 12))

      most_recent_date = my_location.most_recent_event_date
      date = expected_date.strftime('%b %d, %Y')

      expect(most_recent_date).to eq(date)
    end

    describe 'when a location was used only as a session location' do
      it "returns the date of that session's event" do
        session_location = create(:location)
        event = create(:event)
        create(:event_session, event: event, location: session_location)

        expected_time = event.starts_at.in_time_zone(event.time_zone).strftime('%b %d, %Y')
        expect(session_location.most_recent_event_date).to eq(expected_time)
      end
    end
  end

  describe 'inferred time zone' do
    let!(:location) { create(:location) }

    it 'infers time zone from latitude and longtidue' do
      location.latitude = 45
      location.longitude = 45
      expect(location.inferred_time_zone).to eq('Europe/Moscow')
    end

    it 'does not infer time zone when latitude and longitude are not present' do
      location.latitude = nil
      location.longitude = nil
      expect(location.inferred_time_zone).to be_nil
    end
  end
end
