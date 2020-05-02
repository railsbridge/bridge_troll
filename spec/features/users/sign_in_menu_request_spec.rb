# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec/services/omniauth_responses')

describe 'sign in functionality' do
  before do
    @user = create(:user)
  end

  it 'shows on home page on click' do
    visit '/'
    page.find('#sign_in_dialog', visible: :hidden)
    click_link('Sign In')
    page.find('#sign_in_dialog', visible: :visible)
  end

  it 'does not show if signed in' do
    sign_in_as(@user)
    visit '/'
    expect(page).to have_link('Sign Out')
    expect(page).not_to have_link('Sign in')
  end

  describe 'when the user visits an authenticated page, then leaves and goes to an unauthenticated one', js: true do
    context 'with password auth' do
      it 'always returns the user to the current page, instead of the last path Devise remembers' do
        visit '/users'
        within '.alert' do
          expect(page).to have_content('sign in')
        end
        visit '/about'
        expect(page).to have_content("Bridge Troll's Features for Organizers")

        within '.navbar' do
          click_on 'Sign In'
        end

        sign_in_with_modal(@user)

        expect(page).to have_content('Signed in successfully')
        expect(page).to have_content("Bridge Troll's Features for Organizers")
      end
    end

    context 'with omniauth' do
      let(:facebook_response) { OmniauthResponses.facebook_response }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(facebook_response)
        @user.authentications.create(provider: :facebook, uid: facebook_response[:uid])
        visit '/about'
      end

      it 'always returns the user to the current page, instead of the last path Devise remembers' do
        within '.navbar' do
          click_on 'Sign In'
        end

        within '#sign_in_dialog' do
          click_on 'Facebook'
        end

        expect(page).to have_content('Facebook login successful')
        expect(page).to have_content("Bridge Troll's Features for Organizers")
      end
    end
  end

  it 'allows a user to sign in from the home page' do
    visit '/'
    within('#sign_in_dialog') do
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Sign in'
    end
    expect(page).to have_content('Signed in successfully')
  end
end
