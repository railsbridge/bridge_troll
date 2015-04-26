require 'rails_helper'

describe Events::AttendeesController do
  before do
    @event = create(:event)
    @organizer = create(:user)
    @event.organizers << @organizer

    @rsvp = create(:rsvp, event: @event, dietary_info: 'paleo')
    create(:dietary_restriction, rsvp: @rsvp, restriction: 'vegan')

    sign_in @organizer
  end

  describe '#index' do
    it 'responds to csv' do
      get :index, event_id: @event.id, format: :csv
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('text/csv')

      csv_rows = CSV.parse(response.body)
      expect(csv_rows[0][0]).to eq('Name')
      expect(csv_rows[1][0]).to eq(@rsvp.user.full_name)
    end

    it 'includes all dietary info in the dietary info field' do
      get :index, event_id: @event.id, format: :csv
      csv_rows = CSV.parse(response.body, headers: true)
      expect(csv_rows[0]['Dietary Info']).to eq('Vegan, paleo')
    end
  end

  describe "#update" do

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
