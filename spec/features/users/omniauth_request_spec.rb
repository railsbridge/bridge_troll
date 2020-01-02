# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec', 'services', 'omniauth_responses')

describe 'signing in with omniauth' do
  # TODO: why is this needed, they load in the app just fine
  include Devise::Controllers::UrlHelpers
  include Devise::OmniAuth::UrlHelpers

  before do
    OmniAuth.config.test_mode = true
  end

  def sign_in_with(provider)
    visit '/'
    click_on 'Sign In'
    click_on provider
  end

  def associate_with(provider)
    visit edit_user_registration_path
    click_on provider
  end

  context 'with a valid facebook auth' do
    let(:facebook_response) { OmniauthResponses.facebook_response }

    before do
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(facebook_response)
    end

    it 'creates a user and authentication if the user does not exist' do
      sign_in_with('Facebook')

      within '#sign-up' do
        click_on 'Sign up'
      end

      user = User.last
      expect(user).to be_valid
      expect(user.first_name).to eq(facebook_response[:info][:first_name])
      expect(user.last_name).to eq(facebook_response[:info][:last_name])
      expect(user.email).to eq(facebook_response[:info][:email])

      authentication = user.authentications.first
      expect(authentication.provider).to eq('facebook')
      expect(authentication.uid).to eq(facebook_response[:uid])
    end

    it 'creates a new authentication if the user already logged in' do
      user = create(:user)
      sign_in_as user

      associate_with('Facebook')

      authentication = user.authentications.reload.first
      expect(authentication.provider).to eq('facebook')
      expect(authentication.uid).to eq(facebook_response[:uid])
    end
  end

  context 'with a valid google_oauth2 auth' do
    let(:google_oauth2_response) { OmniauthResponses.google_oauth2_response }

    before do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(google_oauth2_response)
    end

    it 'creates a user and authentication if the user does not exist' do
      sign_in_with('Google')

      within '#sign-up' do
        click_on 'Sign up'
      end

      user = User.last
      expect(user).to be_valid
      expect(user.first_name).to eq(google_oauth2_response[:info][:first_name])
      expect(user.last_name).to eq(google_oauth2_response[:info][:last_name])
      expect(user.email).to eq(google_oauth2_response[:info][:email])

      authentication = user.authentications.first
      expect(authentication.provider).to eq('google_oauth2')
      expect(authentication.uid).to eq(google_oauth2_response[:uid])
    end

    it 'creates a new authentication if the user already exists' do
      user = create(:user)
      sign_in_as user

      associate_with('Google')

      authentication = user.authentications.reload.first
      expect(authentication.provider).to eq('google_oauth2')
      expect(authentication.uid).to eq(google_oauth2_response[:uid])
    end
  end

  context 'with a valid twitter auth' do
    let(:twitter_response) { OmniauthResponses.twitter_response }

    before do
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(twitter_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      sign_in_with('Twitter')

      within '#sign-up' do
        fill_in 'Email', with: 'cool_tweeter@example.com'
        click_on 'Sign up'
      end

      user = User.last
      expect(user).to be_valid
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Q Public')
      expect(user.email).to eq('cool_tweeter@example.com')

      authentication = user.authentications.first
      expect(authentication.provider).to eq('twitter')
      expect(authentication.uid).to eq(twitter_response[:uid])
    end
  end

  context 'with a valid meetup auth' do
    let(:meetup_response) { OmniauthResponses.meetup_response }

    before do
      OmniAuth.config.mock_auth[:meetup] = OmniAuth::AuthHash.new(meetup_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      sign_in_with('Meetup')

      within '#sign-up' do
        fill_in 'Email', with: 'meetup_user@example.com'
        click_on 'Sign up'
      end

      user = User.last
      expect(user).to be_valid
      expect(user.first_name).to eq('Franz')
      expect(user.last_name).to eq('Meetuper')
      expect(user.email).to eq('meetup_user@example.com')

      authentication = user.authentications.first
      expect(authentication.provider).to eq('meetup')
      expect(authentication.uid).to eq(meetup_response['uid'].to_s)
    end
  end

  context 'with a valid github auth' do
    let(:github_response) { OmniauthResponses.github_response }

    before do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(github_response)
    end

    it 'creates a user and authentication after the user provides an email' do
      sign_in_with('GitHub')

      within '#sign-up' do
        click_on 'Sign up'
      end

      user = User.last
      expect(user).to be_valid
      expect(user.first_name).to eq('Fancy')
      expect(user.last_name).to eq('Fjords')
      expect(user.email).to eq('ffjords@example.com')

      authentication = user.authentications.first
      expect(authentication.provider).to eq('github')
      expect(authentication.uid).to eq(github_response[:uid])
    end
  end

  describe 'parsing the name attribute' do
    it 'assigns blank first name and last name if name is not present' do
      auth_response = OmniauthResponses.github_response
      auth_response[:info].delete(:name)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      sign_in_with('GitHub')

      expect(find_field('user[first_name]').value).to be_blank
      expect(find_field('user[last_name]').value).to be_blank
    end

    it 'assigns blank first name and last name if name is an empty string' do
      auth_response = OmniauthResponses.github_response
      auth_response[:info][:name] = ''
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      sign_in_with('GitHub')

      expect(find_field('user[first_name]').value).to be_blank
      expect(find_field('user[last_name]').value).to be_blank
    end

    it "assigns just the first name if the 'name' attribute has no spaces" do
      auth_response = OmniauthResponses.github_response
      auth_response[:info][:name] = 'Enigma'
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(auth_response)

      sign_in_with('GitHub')

      expect(find_field('user[first_name]').value).to eq('Enigma')
      expect(find_field('user[last_name]').value).to be_blank
    end
  end

  it 'retains the original return_to location when signing in' do
    facebook_response = OmniauthResponses.facebook_response

    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(facebook_response)

    user = create(:user, admin: true)
    user.authentications.create(provider: :facebook, uid: facebook_response[:uid])

    visit admin_dashboard_path
    within '#sign-in-page' do
      click_on 'Facebook'
    end

    expect(page).to have_content('Admin Dashboard')
  end
end
