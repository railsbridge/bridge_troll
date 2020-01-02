# frozen_string_literal: true

require 'rails_helper'

describe Events::StudentsController do
  let(:student_rsvp) { create(:student_rsvp) }
  let(:event) { student_rsvp.event }
  let(:organizer) { create(:user) }

  before do
    event.organizers << organizer
    sign_in organizer
  end

  describe '#index' do
    it 'responds successfully, with the right headers' do
      get :index, params: { event_id: event.to_param }, format: :csv
      expect(assigns(:students)).to eq(event.student_rsvps)
      expect(response.media_type).to eq('text/csv')
      expect(response).to be_successful

      csv_rows = CSV.parse(response.body)
      expect(csv_rows[0][0]).to eq('Student Name')
      expect(csv_rows[1][0]).to eq(student_rsvp.user.full_name)
    end
  end
end
