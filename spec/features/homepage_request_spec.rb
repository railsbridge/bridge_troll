require 'rails_helper'

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
  end

  describe "navbar" do
    describe "as an unauthenticated user" do
      it "has only sign in / sign up links" do
        visit '/'
        page.all('.navbar li a').map(&:text).should == ['Sign In', 'Sign Up']
      end
    end

    describe "as an authenticated user" do
      before do
        @user = create(:user)
        sign_in_as(@user)
      end

      it 'allows the user to log out or view/edit their account details' do
        visit '/'
        page.all('.navbar li a').map(&:text).should == ['Sign Out', 'Account', 'Profile']
      end
    end
  end
end
