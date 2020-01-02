# frozen_string_literal: true

require 'rails_helper'

describe EventList do
  describe 'filtering by organization' do
    let(:org1) { create(:organization) }
    let(:org2) { create(:organization) }

    let(:org1_chapter) { create(:chapter, organization: org1) }
    let(:org2_chapter) { create(:chapter, organization: org2) }

    let!(:org1_event) { create(:event, chapter: org1_chapter) }
    let!(:org2_event) { create(:event, chapter: org2_chapter) }
    let!(:org1_external_event) { create(:external_event, chapter: org1_chapter) }
    let!(:org2_external_event) { create(:external_event, chapter: org2_chapter) }

    it 'returns only the events from a given organization' do
      events = described_class.new('all', organization_id: org1.id).combined_events
      expect(events).to match_array([org1_event, org1_external_event])
    end
  end

  describe 'when returning datatables json' do
    describe 'searching' do
      search_result_ids = proc do |query|
        json = described_class.new('past', serialization_format: 'dataTables', start: 0, length: 10, search: { 'value' => query }).as_json
        json[:data].map { |e| e[:global_id] }
      end

      before do
        @past_bt_event_location = create(:location, name: 'PBPlace', city: 'PBCity')
        @past_bt_event = create(:event, title: 'PastBridge', location: @past_bt_event_location)
        @past_bt_event.update(starts_at: 5.days.ago, ends_at: 4.days.ago)

        @past_external_event = create(:external_event, name: 'PastExternalBridge', starts_at: 3.days.ago, ends_at: 2.days.ago, location: 'PEBPlace')
      end

      it 'can search by event name' do
        expect(search_result_ids.call('PastBridge')).to match_array([@past_bt_event.to_global_id.to_s])
        expect(search_result_ids.call('PastExternalBridge')).to match_array([@past_external_event.to_global_id.to_s])
      end

      it 'can search by event location' do
        expect(search_result_ids.call('PBPlace')).to match_array([@past_bt_event.to_global_id.to_s])
        expect(search_result_ids.call('PBCity')).to match_array([@past_bt_event.to_global_id.to_s])
        expect(search_result_ids.call('PEBPlace')).to match_array([@past_external_event.to_global_id.to_s])
      end
    end
  end

  describe 'csv' do
    let(:meetup_event_url) { 'https://example.com' }

    let!(:event) { create(:event) }
    let!(:meetup_event) do
      imported_event_data = { 'student_event' => { 'url' => meetup_event_url } }
      create(:event, imported_event_data: imported_event_data)
    end
    let!(:external_event) { create(:external_event) }

    it 'aggregates data for bridgetroll and external events' do
      csv = described_class.new('all').to_csv
      expect(csv).to include(event.title)
      expect(csv).to include(external_event.title)
      expect(csv).to include(meetup_event.title)
      expect(csv).to include(meetup_event_url)
    end
  end
end
