require 'spec_helper'

describe "visiting the home page" do
  describe "as an unauthenticated user" do
    let(:new_user_form_values) { {
      :first_name => "Jane",
      :last_name => "Doe",
      :email => "jane@doe.com",
      :password => "password"
    } }

    it "can sign up" do
      visit '/'

      click_link 'Sign Up'
      within("#sign-up") do
        fill_in "user_first_name", :with => new_user_form_values[:first_name]
        fill_in "user_last_name", :with => new_user_form_values[:last_name]
        fill_in "Email", :with => new_user_form_values[:email]
        fill_in 'user_password', with: new_user_form_values[:password]
        fill_in 'user_password_confirmation', with: new_user_form_values[:password]
        click_button 'Sign up'
      end
      page.should have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
    end

    it "is prompted to Sign In/Up but not to view Profile" do
      visit '/'
      page.should have_link("Sign In")
      page.should have_link("Sign Up")
      page.should_not have_link("Profile")
    end
  end

  describe "as an authenticated user" do
    before do
      @user = create(:user)
      sign_in_as(@user)
    end

    it 'is prompted to view Profile but not Sign In/Up' do
      visit '/'
      page.should_not have_link("Sign In")
      page.should_not have_link("Sign Up")
      page.should have_link("Profile")
    end

    it 'is prompted to connect their meetup account' do
      visit '/'
      within '.alert' do
        page.should have_link 'Connect to Meetup.com'
        click_button '×'
      end
      page.should_not have_link 'Connect to Meetup.com'
    end
  end
end
