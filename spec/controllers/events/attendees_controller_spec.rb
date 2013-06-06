require 'spec_helper'

describe Events::AttendeesController do
  describe "#update" do
    before do
      @event = create(:event)
      @organizer = create(:user)
      @event.organizers << @organizer

      @rsvp = create(:rsvp, event: @event)

      sign_in @organizer
    end

    let(:do_request) do
      put :update, event_id: @event.id, id: @rsvp.id, attendee: {
        section_id: 401,
        subject_experience: 'Some awesome string'
      }
    end

    it 'allows organizers to update an attendee\'s section_id' do
      expect {
        do_request
      }.to change { @rsvp.reload.section_id }.to(401)
    end

    it 'does not allow updates to columns other than section_id' do
      expect {
        do_request
      }.not_to change { @rsvp.reload.subject_experience }
    end
  end
end
