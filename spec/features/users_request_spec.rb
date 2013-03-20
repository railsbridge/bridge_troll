require 'spec_helper'

describe "new user" do
  it "should be able to signup" do
    @user = User.new(:first_name=>"Anne", :last_name =>"Hall", :email=>"example@example.com", :password=>"booboo")

    visit new_user_registration_path

    fill_in "user_first_name", :with => @user.first_name
    fill_in "user_last_name",  :with => @user.last_name
    fill_in "Email", :with => @user.email
    fill_in 'user_password', with: @user.password
    fill_in 'user_password_confirmation', with: @user.password
    click_button "Sign up"
    page.should have_content("A message with a confirmation link has been sent to your email address. Please open the link to activate your account.")
  end
end

describe "existing user" do
  before do
    @user = create(:user)
  end

  it "should see Sign In and should not see Profile link on the home page" do
    visit '/'
    page.should have_link("Sign In")
    page.should_not have_link("Profile")
  end

  it "should be able to sign in from the home page" do
    visit '/'
    click_link("Sign In")
    page.should have_content("Sign in")
    current_path.should == new_user_session_path
  end

  describe "is signed in" do
    before do
      sign_in_as(@user)
    end

    it "should see Sign Out link and Profile links and not see Sign In/Up links" do
      page.should have_link("Profile")
      page.should have_link("Sign Out")
      page.should_not have_link("Sign In")
      page.should_not have_link("Sign Up")
    end
  end

  it "should see sign up link on the home page" do
    visit '/'
    page.should have_link("Sign Up")
  end

  it "should be able to sign up from the home page" do
    visit '/'
    click_link("Sign Up")
    page.should have_content("Sign up")
    current_path.should == new_user_registration_path
  end

  describe "skills" do
    before do
      sign_in_as(@user)
    end

    it "link to add skills should be present on the home page for logged in user" do
      page.should have_link("Profile")
    end
  end
end
