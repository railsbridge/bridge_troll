require 'spec_helper'
require Rails.root.join('spec', 'services', 'omniauth_responses')

describe "signing in with omniauth" do
  before do
    OmniAuth.config.test_mode = true
  end

  context "with a valid facebook auth" do
    let(:facebook_response) { OmniauthResponses.facebook_response }

    before do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(facebook_response)
    end

    it 'creates a user and authentication if the user does not exist' do
      visit user_omniauth_authorize_path(:facebook)

      click_on 'Sign up'

      user = User.last
      user.first_name.should == facebook_response[:info][:first_name]
      user.last_name.should == facebook_response[:info][:last_name]
      user.email.should == facebook_response[:info][:email]

      authentication = user.authentications.first
      authentication.provider.should == 'facebook'
      authentication.uid.should == facebook_response[:uid]
    end

    it 'creates a new authentication if the user already exists' do
      @user = create(:user)
      sign_in_as @user

      visit user_omniauth_authorize_path(:facebook)

      authentication = @user.authentications.first
      authentication.provider.should == 'facebook'
      authentication.uid.should == facebook_response[:uid]
    end
  end

  context "with a valid twitter auth" do
    let(:twitter_response) { OmniauthResponses.twitter_response }

    before do
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(twitter_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      visit user_omniauth_authorize_path(:twitter)

      within '#sign-up' do
        fill_in 'Email', with: 'cool_tweeter@example.com'
      end

      click_on 'Sign up'

      user = User.last
      user.first_name.should == "John"
      user.last_name.should == "Q Public"
      user.email.should == "cool_tweeter@example.com"

      authentication = user.authentications.first
      authentication.provider.should == 'twitter'
      authentication.uid.should == twitter_response[:uid]
    end
  end
end