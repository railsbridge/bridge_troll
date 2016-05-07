require 'rails_helper'

describe "visiting the home page" do
  describe "as an unauthenticated user" do
    let(:new_user_form_values) { {
      first_name: "Jane",
      last_name: "Doe",
      email: "jane@doe.com",
      password: "password"
    } }

    it "can sign up" do
      visit '/'

      click_link 'Sign Up'
      within("#sign-up") do
        fill_in "user_first_name", with: new_user_form_values[:first_name]
        fill_in "user_last_name", with: new_user_form_values[:last_name]
        fill_in "Email", with: new_user_form_values[:email]
        fill_in 'user_password', with: new_user_form_values[:password]
        fill_in 'user_password_confirmation', with: new_user_form_values[:password]
        click_button 'Sign up'
      end
      expect(page).to have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
    end

    it "has a sign up link in the upcoming events section" do
      visit '/'
      within '.event-notifications' do
        expect(page).to have_link('sign up', href: new_user_registration_path)
        expect(page).to have_text('to receive email notifications')
      end
    end
  end

  describe "as an authenticated user" do
    before do
      @user = create(:user)
      sign_in_as(@user)
    end

    it "has a link to email notification preferences" do
      visit '/'
      within '.event-notifications' do
        expect(page).to have_link('event notification email preferences', href: edit_user_registration_path)
      end
    end
  end

  describe "navbar" do
    describe "as an unauthenticated user" do
      it "has only sign in / sign up links" do
        visit '/'
        expect(page.all('.navbar li a').map(&:text)).to eq(['Sign In', 'Sign Up'])
      end
    end

    describe "as an authenticated user" do
      before do
        @user = create(:user)
        sign_in_as(@user)
      end

      it 'allows the user to log out or view/edit their account details' do
        visit '/'
        expect(page.all('.navbar li a').map(&:text)).to eq([@user.full_name, 'Sign Out'])
      end
    end
  end
end
