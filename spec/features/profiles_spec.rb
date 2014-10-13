require 'rails_helper'

describe "Profile" do
  before do
    @user = create(:user)
    profile_attributes = {
      childcaring: true,
      writing: true,
      designing: true,
      outreach: true,
      mentoring: true,
      macosx: true,
      windows: true,
      linux: true,
      other: "This is a note in other",
      bio: "This is a Bio",
      github_username: "sally33"
    }
    @user.profile.update_attributes(profile_attributes)

    sign_in_as(@user)
  end

  it "when user visits the profile show page should see" do
    visit user_profile_path(@user)

    page.should have_content(@user.full_name)
    page.should have_content(@user.profile.other)
    page.should have_content(@user.profile.bio)
    page.should have_content(@user.profile.github_username)
    page.should have_content("Childcare")
    page.should have_content("Writer")
    page.should have_content("Designer")
    page.should have_content("Mentor")
    page.should have_content("Outreach")
    page.should have_content("Windows")
    page.should have_content("Mac OS X")
    page.should have_content("Linux")
  end

  it "user should be able to add his/her skills" do
    skill_settings = {
      "Childcare" => false,
      "Writer" => false,
      "Designer" => false,
      "Outreach" => true,
      "Mentor" => true,
      "Windows" => true,
      "Mac OS X" => false,
      "Linux" => true
    }

    visit "/"
    click_link "Settings"
    page.should have_content("Edit User")

    within '.checkbox-columns-small' do
      skill_settings.each do |label, value|
        page.send(value ? :check : :uncheck, label)
      end
    end

    fill_in "Other Skills", with: "Speaking Spanish"
    fill_in "Bio", with: "This is my bio..."
    fill_in "Github username", with: "sally33"

    click_button "Update"

    page.should have_content("You updated your account successfully")

    visit user_profile_path(@user)

    skill_settings.each do |label, value|
      page.send(value ? :should : :should_not, have_content(label))
    end

    page.should have_content("Speaking Spanish")
    page.should have_content("This is my bio...")
    page.should have_content("sally33")
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