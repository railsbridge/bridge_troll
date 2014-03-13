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

  context "with a valid github auth" do
    let(:github_response) { OmniauthResponses.github_response }

    before do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(github_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      visit user_omniauth_authorize_path(:github)

      click_on 'Sign up'

      user = User.last
      user.first_name.should == "Fancy"
      user.last_name.should == "Fjords"
      user.email.should == "ffjords@example.com"

      authentication = user.authentications.first
      authentication.provider.should == 'github'
      authentication.uid.should == github_response[:uid]
    end
  end

  context "when the omniauth provider sends a nil 'full name' field" do
    before do
      auth_response = OmniauthResponses.github_response
      auth_response[:info].delete(:name)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)
    end

    it 'requires the user to enter first_name and last_name and authentication after the user provides an email' do
      visit user_omniauth_authorize_path(:github)

      find_field('user[first_name]').value.should be_blank
      find_field('user[last_name]').value.should be_blank

      fill_in 'user[first_name]', with: 'Dan'
      fill_in 'user[last_name]', with: 'Danson'

      click_on 'Sign up'

      user = User.last
      user.first_name.should == "Dan"
      user.last_name.should == "Danson"
      user.email.should == "ffjords@example.com"
    end
  end
end