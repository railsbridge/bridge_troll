# frozen_string_literal: true

require 'rails_helper'

describe EventSessionsController do
  render_views

  describe '#index' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    before do
      sign_in user
    end

    describe 'an unauthorized user' do
      it 'cannot see a list of attendees' do
        expect(
          get(:index, params: { event_id: event.id })
        ).to be_redirect
      end
    end

    describe 'an organizer' do
      before do
        event.organizers << user
      end

      it 'can see a list of attendees' do
        expect(
          get(:index, params: { event_id: event.id })
        ).not_to be_redirect
      end
    end
  end

  describe '#show' do
    let(:user) { create(:user, time_zone: 'Alaska') }
    let(:event) { create(:event, title: 'DogeBridge') }
    let(:event_session) { event.event_sessions.first }

    before do
      sign_in user
    end

    context 'format is ics' do
      it 'responds with success' do
        get :show, params: { event_id: event.id, id: event_session.id }, format: 'ics'
        expect(response).to be_successful
      end

      it 'delegates to IcsGenerator' do
        generator = instance_double(IcsGenerator, event_session_ics: 'CALENDAR STUFF')
        allow(IcsGenerator).to receive(:new).and_return(generator)
        expect(IcsGenerator).to receive(:new)

        get :show, params: { event_id: event.id, id: event_session.id }, format: 'ics'
      end
    end

    context 'format is not ics' do
      it 'responds with not_found' do
        get :show, params: { event_id: event.id, id: event_session.id }
        expect(response).to be_not_found
      end
    end
  end
end
