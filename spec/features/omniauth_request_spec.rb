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

  context "with a valid meetup auth" do
    let(:meetup_response) { OmniauthResponses.meetup_response }

    before do
      OmniAuth.config.mock_auth[:meetup] = OmniAuth::AuthHash.new(meetup_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      visit user_omniauth_authorize_path(:meetup)

      within '#sign-up' do
        fill_in 'Email', with: 'meetup_user@example.com'
      end

      click_on 'Sign up'

      user = User.last
      user.first_name.should == "Franz"
      user.last_name.should == "Meetuper"
      user.email.should == "meetup_user@example.com"

      authentication = user.authentications.first
      authentication.provider.should == 'meetup'
      authentication.uid.should == meetup_response['uid'].to_s
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

  describe "parsing the name attribute" do
    it "assigns blank first name and last name if name is not present" do
      auth_response = OmniauthResponses.github_response
      auth_response[:info].delete(:name)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      visit user_omniauth_authorize_path(:github)

      find_field('user[first_name]').value.should be_blank
      find_field('user[last_name]').value.should be_blank
    end

    it "assigns blank first name and last name if name is an empty string" do
      auth_response = OmniauthResponses.github_response
      auth_response[:info][:name] = ''
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      visit user_omniauth_authorize_path(:github)

      find_field('user[first_name]').value.should be_blank
      find_field('user[last_name]').value.should be_blank
    end

    it "assigns just the first name if the 'name' attribute has no spaces" do
      auth_response = OmniauthResponses.github_response
      auth_response[:info][:name] = 'Enigma'
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      visit user_omniauth_authorize_path(:github)

      find_field('user[first_name]').value.should == 'Enigma'
      find_field('user[last_name]').value.should be_blank
    end
  end
end