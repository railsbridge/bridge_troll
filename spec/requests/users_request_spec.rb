require 'spec_helper'

describe "new user" do
  it "should be able to signup" do
    @user = User.new(:first_name=>"Anne", :last_name =>"Hall", :email=>"example@example.com", :password=>"booboo")

    visit new_user_registration_path

    fill_in "user_first_name", :with => @user.first_name
    fill_in "user_last_name",  :with => @user.last_name
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    fill_in "Password confirmation", :with => @user.password
    click_button "Sign up"
    page.should have_content("A message with a confirmation link has been sent to your email address. Please open the link to activate your account.")
  end
end

describe "existing user" do
  before do
    @user = create(:user)
  end

  it "should see Sign In and should not see Add Your Skills link on the home page" do
    visit '/'
    page.should have_link("Sign In")
    page.should_not have_link("Add Your Skills")
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

    it "should see Sign Out link and Add Your Skills links and not see Sign In/Up links" do
      page.should have_link("Add Your Skills")
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
      page.should have_link("Add Your Skills")
    end

    it "user should be able to add his/her skills" do
      click_link "Add Your Skills"
      page.should have_content("My Incredible Powers")

      check "profile_teaching"
      check "profile_taing"
      check "profile_coordinating"
      check "profile_childcaring"
      check "profile_writing"
      check "profile_hacking"
      check "profile_designing"
      page.should have_content("Evangelizing")
      page.should have_content("Mentoring")
      page.should have_content("Windows")

      fill_in "profile_other", :with => "Speaking Spanish"

      click_button "Update"

      user = User.find(@user.id)
      profile = user.profile

      profile.teaching.should be_true
      profile.taing.should be_true
      profile.coordinating.should be_true
      profile.childcaring.should be_true
      profile.writing.should be_true
      profile.hacking.should be_true
      profile.designing.should be_true
      profile.evangelizing.should be_false
      profile.mentoring.should be_false
      profile.other.should == "Speaking Spanish"
    end
  end
end