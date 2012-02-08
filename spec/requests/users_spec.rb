require 'spec_helper'

describe "existing user", :js => true do

  before(:each) do
    @user = Factory(:user)
    @user.confirm!
  end

  it "should see sign in link on the home page" do
    visit '/'
    page.should have_link("Sign In")
  end

  it "should see be able to sign in from the home page" do
    visit '/'
    click_link("Sign In")
    current_path.should == new_user_session_path
  end

  it "should be able to sign in from the sign in page" do
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    page.should have_content("Signed in successfully")
    page.should have_link("Sign Out")
  end

  describe "skills" do
    before do
      visit new_user_session_path

      fill_in "Email", :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"

      wait_until{page.has_content?("Signed in successfully")}
    end

    it "link to add skills should be present on the home page for logged in user" do
      page.should have_link("Add Your Skills")
    end

    it "user should be able to add his/her skills" do
      click_link "Add Your Skills"

      page.should have_content("My Incredible Powers")

      check "Teaching"
      check "TAing"
      check "Coordinating"
      check "Childcaring"
      check "Writing"
      check "Hacking"
      check "Designing"
      page.should have_content("Evangelizing")
      page.should have_content("Mentoring")
      page.should have_content("Mac OS X")
      page.should have_content("Windows")
      page.should have_content("Linux/Ubuntu")

      fill_in "Other", :with => "Speaking Spanish"

      click_button "Submit"

      page.should have_content("Thanks for adding your skills")

      @user.skill_teaching.should be_true
      @user.skill_taing.should be_true
      @user.skill_coordinating.should be_true
      @user.skill_childcaring.should be_true
      @user.skill_writing.should be_true
      @user.skill_hacking.should be_true
      @user.skill_designing.should be_true
      @user.skill_evangelizing.should be_false
      @user.skill_mentoring.should be_false
      @user.skill_other.should == "Speaking Spanish"

    end
  end
end