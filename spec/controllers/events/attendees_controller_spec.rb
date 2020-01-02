# frozen_string_literal: true

require 'rails_helper'

describe Events::AttendeesController do
  before do
    @event = create(:event)
    @organizer = create(:user, first_name: 'Apple', last_name: 'Pearson')
    @event.organizers << @organizer

    rsvp_user = create(:user, first_name: 'Snake', last_name: 'Snakeson')
    @rsvp = create(:rsvp, event: @event, user: rsvp_user, dietary_info: 'paleo')
    create(:dietary_restriction, rsvp: @rsvp, restriction: 'vegan')

    sign_in @organizer
  end

  describe '#index' do
    it 'responds to csv' do
      get :index, params: { event_id: @event.id }, format: :csv
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/csv')

      csv_rows = CSV.parse(response.body)
      expect(csv_rows[0][0]).to eq('Name')
      expect(csv_rows[1][0]).to eq(@organizer.full_name)
      expect(csv_rows[2][0]).to eq(@rsvp.user.full_name)
    end

    it 'includes organizers in csv' do
      get :index, params: { event_id: @event.id }, format: :csv
      csv_rows = CSV.parse(response.body, headers: true)
      expect(csv_rows[0]['Attending As']).to eq('Organizer')
    end

    it 'includes all dietary info in the dietary info field' do
      get :index, params: { event_id: @event.id }, format: :csv
      csv_rows = CSV.parse(response.body, headers: true)
      expect(csv_rows[1]['Dietary Info']).to eq('Vegan, paleo')
    end

    it 'orders RSVPs by user name' do
      another_user = create(:user, first_name: 'Xylophone', last_name: 'Xyson')
      create(:rsvp, event: @event, user: another_user)

      get :index, params: { event_id: @event.id }, format: :csv
      csv_rows = CSV.parse(response.body, headers: true)
      expected = [
        'Apple Pearson',
        'Snake Snakeson',
        'Xylophone Xyson'
      ]
      expect(csv_rows.map { |c| c['Name'] }).to eq(expected)
    end
  end

  describe '#update' do
    let!(:section) { create(:section, event: @event) }

    let(:do_request) do
      put :update, params: { event_id: @event.id, id: @rsvp.id, attendee: {
        section_id: section.id,
        subject_experience: 'Some awesome string'
      } }
    end

    it 'allows organizers to update an attendee\'s section_id' do
      expect do
        do_request
      end.to change { @rsvp.reload.section_id }.to(section.id)
    end

    it 'does not allow updates to columns other than section_id' do
      expect do
        do_request
      end.not_to(change { @rsvp.reload.subject_experience })
    end
  end
end
