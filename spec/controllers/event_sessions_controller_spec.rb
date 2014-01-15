require 'spec_helper'

describe EventSessionsController do
  render_views

  describe '#show' do
    before do
      @user = create(:user, time_zone: 'Alaska')
      sign_in @user
      @event = create(:event, title: 'DogeBridge')
      @event_session = @event.event_sessions.first
    end

    context 'format is ics' do
      it 'responds with success' do
        get :show, format: 'ics', event_id: @event.id, id: @event_session.id
        response.should be_success
      end

      it 'delegates to IcsGenerator' do
        generator = double(event_session_ics: 'CALENDAR STUFF')
        IcsGenerator.should_receive(:new).and_return(generator)

        get :show, format: 'ics', event_id: @event.id, id: @event_session.id
      end
    end

    context 'format is not ics' do
      it 'responds with not_found' do
        get :show, event_id: @event.id, id: @event_session.id
        response.should be_not_found
      end
    end
  end

end
