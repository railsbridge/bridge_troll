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
      events = EventList.new('all', organization_id: org1.id).combined_events
      expect(events).to match_array([org1_event, org1_external_event])
    end
  end
end
