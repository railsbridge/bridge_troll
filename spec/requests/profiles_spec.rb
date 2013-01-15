require 'spec_helper'

describe "Profile" do
  before do
    @user = create(:user)
    @user.profile.update_attributes( :teaching => true,
                                     :taing => true,
                                     :coordinating => true,
                                     :childcaring => true,
                                     :writing => true,
                                     :hacking => true,
                                     :designing => true,
                                     :evangelizing => true,
                                     :mentoring => true,
                                     :macosx => true,
                                     :windows => true,
                                     :linux => true,
                                     :other => "This is a note in other",
                                     :bio => "This is a Bio"
    )

    sign_in_as(@user)
  end

  it "when a user is logged in the Profile link should be displayed" do
    page.should have_link("Profile")
  end

  it "and the user clicks the Profile link" do
    click_link "Profile"
  end

  it "when user visits the profile show page should see" do
    click_link "Profile"
    page.should have_content(@user.full_name)
    page.should have_content(@user.profile.bio)
    page.should have_content("Teacher")
    page.should have_content("Teacher Assistant")
    page.should have_content("Coordinator")
    page.should have_content("Childcare")
    page.should have_content("Writer")
    page.should have_content("Hacker")
    page.should have_content("Designer")
    page.should have_content("Evangelize")
    page.should have_content("Mentor")
    page.should have_content("Windows")
    page.should have_content("Mac OS X")
    page.should have_content("Linux")
    page.should have_content("This is a note in other")
    page.should have_content("This is a Bio")
    page.should have_content("Workshop History")
  end

  it "user should be able to add his/her skills" do
    click_link "Profile"
    click_link "edit profile"
    page.should have_content("Profile edit #{@user.full_name}")

    check "profile_teaching"
    check "profile_taing"
    uncheck "profile_coordinating"
    uncheck "profile_childcaring"
    uncheck "profile_writing"
    check "profile_hacking"
    uncheck "profile_designing"
    check "profile_evangelizing"
    check "profile_mentoring"
    check "profile_windows"
    uncheck "profile_macosx"
    check "profile_linux"

    fill_in "profile_other", :with => "Speaking Spanish"
    fill_in "profile_bio", :with => "This is my bio..."

    click_button "Update"

    page.should have_content("Profile was successfully updated.")
    page.should have_content("Teacher")
    page.should have_content("Teacher Assistant")
    page.should_not have_content("Coordinator")
    page.should_not have_content("Childcare")
    page.should_not have_content("Writer")
    page.should have_content("Hacker")
    page.should_not have_content("Designer")
    page.should have_content("Evangelize")
    page.should have_content("Mentor")
    page.should have_content("Windows")
    page.should_not have_content("Mac OS X")
    page.should have_content("Linux")
    page.should have_content("Speaking Spanish")
    page.should have_content("This is my bio...")
  end

  it "should be able to see workshop history" do
    click_link "Profile"
    page.should have_content("Workshop History")
    page.should have_content("Role")
    page.should have_content("Date")
    page.should have_content("Venue")
  end
end