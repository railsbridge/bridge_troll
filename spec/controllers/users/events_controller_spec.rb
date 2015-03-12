require 'rails_helper'

describe Users::EventsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event) }
  let!(:rsvp) { FactoryGirl.create(:rsvp, user: user, event: event,
                                   checkins_count: 1) }

  describe "#index" do
    it 'should respond successfully with json' do
      get :index, user_id: user.id
      response.content_type.should == 'application/json'
      response.should be_success
    end

    it 'should respond with the correct count' do
      get :index, user_id: user.id
      expected_response = {event_count: 1}.to_json
      response.body.should == expected_response
    end
  end
end
