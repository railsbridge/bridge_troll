require 'rails_helper'

describe Users::EventsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event) }
  let!(:rsvp) { FactoryGirl.create(:rsvp, user: user, event: event,
                                   checkins_count: 1) }

  describe "#index" do
    it 'should respond successfully with json' do
      get :index, user_id: user.id
      expect(response.content_type).to eq('application/json')
      expect(response).to be_success
    end

    it 'should respond with the correct count' do
      get :index, user_id: user.id
      expected_response = {event_count: 1}.to_json
      expect(response.body).to eq(expected_response)
    end
  end
end
