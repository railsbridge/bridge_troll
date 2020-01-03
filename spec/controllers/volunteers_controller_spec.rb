# frozen_string_literal: true

require 'rails_helper'

describe VolunteersController do
  let!(:event) { create(:event) }
  let!(:user_organizer) { create(:user) }
  let!(:vol1) { create(:user, first_name: 'Vol1') }
  let!(:vol2) { create(:user, first_name: 'Vol2') }
  let!(:vol3) { create(:user, first_name: 'Vol3') }

  before do
    event.organizers << user_organizer
    create(:teacher_rsvp, user: vol1, event: event)
    create(:teacher_rsvp, user: vol2, event: event)
    create(:teacher_rsvp, user: vol3, event: event)
    sign_in user_organizer
  end

  context 'a user that is logged in and is an organizer for the event' do
    describe 'index' do
      render_views

      it 'is able to see list of volunteers' do
        get :index, params: { event_id: event.id }
        expect(response).to be_successful

        expect(response.body).to have_content 'Vol1'
        expect(response.body).to have_content 'Vol2'
        expect(response.body).to have_content 'Vol3'
      end
    end
  end
end
