require 'rails_helper'

describe MeetupImporter do
  let(:volunteer_event_id) { 1234 }
  let(:student_event_id) { 5678 }

  let(:sven) { {name: 'Sven Volunteeren', id: 2599323} }
  let(:sally) { {name: 'Sally Voluntally', id: 2604303} }

  before do
    @importer = MeetupImporter.new
  end

  describe "association to meetup users" do
    let(:bridgetroll_user) { create(:user) }

    before do
      imported_event_data = {
        type: 'meetup',
        student_event: {
          id: volunteer_event_id,
          url: 'http://example.com/901'
        }, volunteer_event: {
          id: student_event_id,
          url: 'http://example.com/901'
        }
      }

      @event = create(:event, imported_event_data: imported_event_data)

      @sven_model = create(:meetup_user, full_name: sven[:name], meetup_id: sven[:id])
      create(:rsvp, user: @sven_model, event: @event)
      @sally_model = create(:meetup_user, full_name: sally[:name], meetup_id: sally[:id])
      create(:rsvp, user: @sally_model, event: @event)
    end

    it "can associate users who have no meetup RSVPs" do
      bridgetroll_user.authentications.create(provider: 'meetup', uid: '123456789')

      expect(bridgetroll_user.reload.meetup_id).to eq('123456789')
      expect(bridgetroll_user.rsvps.length).to eq(0)
    end

    it "claims existing RSVPs when associating" do
      expect(@event.volunteers_with_legacy).to match_array([@sven_model, @sally_model])

      bridgetroll_user.authentications.create(provider: 'meetup', uid: sven[:id].to_s)

      expect(@event.reload.volunteers_with_legacy).to match_array([bridgetroll_user, @sally_model])
    end

    context "when a bridgetroll user is already associated to a meetup user" do
      before do
        bridgetroll_user.authentications.create(provider: 'meetup', uid: sven[:id].to_s)
      end

      it "removes claim to RSVPs when disassociating" do
        @importer.disassociate_user(bridgetroll_user)

        expect(@event.reload.volunteers_with_legacy).to match_array([@sven_model, @sally_model])
      end
    end
  end
end