require 'rails_helper'

describe Users::EventsController do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event) }
  let!(:rsvp) { FactoryBot.create(:rsvp, user: user, event: event,
                                   checkins_count: 1) }

  describe "#index" do
    it 'should respond successfully with json' do
      get :index, params: { user_id: user.id }
      expect(response.content_type).to eq('application/json')
      expect(response).to be_success
    end

    it 'should respond with the correct count' do
      get :index, params: { user_id: user.id }
      expected_response = {event_count: 1}.to_json
      expect(response.body).to eq(expected_response)
    end
  end
end
