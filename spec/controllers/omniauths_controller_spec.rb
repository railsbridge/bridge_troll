require 'spec_helper'
require Rails.root.join('spec', 'services', 'omniauth_responses')

describe OmniauthsController do
  context "after meetup hits the callback" do
    before do
      @user = create(:user)
      sign_in @user

      OmniAuth.config.test_mode = true
      authed_params = OmniauthResponses.meetup_response(7654321)
      OmniAuth.config.mock_auth[:meetup] = OmniAuth::AuthHash.new(authed_params)
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:meetup]
    end

    it 'informs the meetup importer that this bridgetroll user has claimed this meetup user' do
      MeetupImporter.any_instance.should_receive(:associate_user).with(@user, 7654321)

      get :callback, provider: :meetup
    end
  end
end