require 'spec_helper'

describe "existing user", :js => true do

  before(:each) do
    @user = Factory(:user)
    @user.confirm!

    #@event = Factory(:event)
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
  
  it "should signin and edit his/her settings" do
    pending
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    page.should have_content("Signed in successfully")

    page.should have_content("Become Volunteer")

    click_link "Become A Volunteer"

    page.should have_content("specify your skills")

    check("Coordinating")
    check("Teaching")
    check("TAing")
    check("Mentoring")
    check("Childcaring")
    check("Writing")
    page.should have_content("Evangelizing")
    page.should have_content("Other")

    click_button "Submit"

    page.should have_content("Thanks for submitting your skills")

    page.should have_no_content("Become A Volunteer")

    @user.skills.should == ["Coordinating", "Teaching", "TAing", "Mentoring", "Hacking", "Designing", "Childcaring", "Writing"]

    page.should have_content("Update your skills")

    click_link "Update your skills"

    page.should have_content("specify your skills")

    uncheck("Hacking")
    uncheck("Designing")

    click_button "Submit"

    page.should have_content("Thanks for submitting your skills")

    @user.skills.should == ["Coordinating", "Teaching", "TAing", "Mentoring", "Childcaring", "Writing"]


  end

end