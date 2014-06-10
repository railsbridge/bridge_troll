require 'rails_helper'

describe "Profile" do
  before do
    @user = create(:user)
    @user.profile.update_attributes(:childcaring => true,
                                    :writing => true,
                                    :designing => true,
                                    :outreach => true,
                                    :mentoring => true,
                                    :macosx => true,
                                    :windows => true,
                                    :linux => true,
                                    :other => "This is a note in other",
                                    :bio => "This is a Bio"
    )

    sign_in_as(@user)
  end

  it "when user visits the profile show page should see" do
    visit "/"
    click_link "Profile"
    page.should have_content(@user.full_name)
    page.should have_content(@user.profile.bio)
    page.should have_content("Childcare")
    page.should have_content("Writer")
    page.should have_content("Designer")
    page.should have_content("Mentor")
    page.should have_content("Outreach")
    page.should have_content("Windows")
    page.should have_content("Mac OS X")
    page.should have_content("Linux")
    page.should have_content("This is a note in other")
    page.should have_content("This is a Bio")
    page.should have_content("Workshop History")
  end

  it "user should be able to add his/her skills" do
    visit "/"
    click_link "Profile"
    click_link "Edit Profile"
    page.should have_content("Profile edit #{@user.full_name}")

    uncheck "profile_childcaring"
    uncheck "profile_writing"
    uncheck "profile_designing"
    check "profile_outreach"
    check "profile_mentoring"
    check "profile_windows"
    uncheck "profile_macosx"
    check "profile_linux"

    fill_in "profile_other", :with => "Speaking Spanish"
    fill_in "profile_bio", :with => "This is my bio..."

    click_button "Update"

    page.should have_content("Profile was successfully updated.")
    page.should_not have_content("Childcare")
    page.should_not have_content("Writer")
    page.should have_content("Outreach")
    page.should_not have_content("Designer")
    page.should have_content("Mentor")
    page.should have_content("Windows")
    page.should_not have_content("Mac OS X")
    page.should have_content("Linux")
    page.should have_content("Speaking Spanish")
    page.should have_content("This is my bio...")
  end

  context "when the user has attended some workshops" do
    before do
      event = create(:event, title: 'BridgeBridge')
      event.rsvps << create(:rsvp, user: @user, event: event)
    end

    it "should be able to see workshop history" do
      visit user_profile_path(@user)
      page.should have_content("Workshop History")
      page.should have_content("BridgeBridge")
    end
  end
end