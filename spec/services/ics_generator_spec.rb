require 'spec_helper'

describe IcsGenerator do
  describe '#event_session_ics' do
    let(:event) { build(:event, title: 'Test Event', location: build(:location, name: 'Office Labs')) }
    let(:event_session) { double(event: event, starts_at: Date.tomorrow, ends_at: Date.tomorrow, name: 'Best Session!') }

    it 'delegates to Icalendar' do
      IcsGenerator::Calendar.should_receive(:new).and_call_original
      IcsGenerator.new.event_session_ics(event_session)
    end
  end
end
