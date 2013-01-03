require 'spec_helper'


describe "new user", :js => true do
  it "should be able to signup" do
    @user = User.new(:name=>"Anne", :email=>"example@example.com", :password=>"booboo")

    visit new_user_registration_path

    fill_in "Name", :with => @user.name
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    fill_in "Password confirmation", :with => @user.password
    click_button "Sign up"
    page.should have_content("A message with a confirmation link has been sent to your email address. Please open the link to activate your account.")
  end
end

describe "existing user", :js => true do
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
      fill_in "user_current_password", :with=> @user.password
      page.should have_content("My Incredible Powers")

      check "user_teaching"
      check "user_taing"
      check "user_coordinating"
      check "user_childcaring"
      check "user_writing"
      check "user_hacking"
      check "user_designing"
      page.should have_content("Evangelizing")
      page.should have_content("Mentoring")
      page.should have_content("Windows")

      fill_in "Other", :with => "Speaking Spanish"

      click_button "Update"

      @user = User.find(@user.id)

      @user.teaching.should be_true
      @user.taing.should be_true
      @user.coordinating.should be_true
      @user.childcaring.should be_true
      @user.writing.should be_true
      @user.hacking.should be_true
      @user.designing.should be_true
      @user.evangelizing.should be_false
      @user.mentoring.should be_false
      @user.other.should == "Speaking Spanish"
    end
  end
end
