require 'spec_helper'

describe "Event Organizers" do
  before do
    @user_organizer = create(:user, email: "orgainzer@mail.com", first_name: "Sam", last_name: "Spade")
    @user1 = create(:user, email: "user1@mail.com", first_name: "Joe", last_name: "Cairo")

    @user1.update_attributes(:hacking => true, :teaching => true)

    @event = create(:event)

    @rsvp1 = VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)

    @event.organizers << @user_organizer

    sign_in_as(@user_organizer)

    visit "/events/#{@event.id}/organizers"
  end

  it "should display the Manage Organizers Page" do
    page.should have_content("Organizer Assignments")
  end

  it "should not have a Remove button for the organizer viewing the page" do
    page.should_not have_selector('input[value="Remove"]')
  end

  it "should display the assigned organizers email" do
    page.should have_content("orgainzer@mail.com")
    page.should have_content("Sam Spade")
  end

  it "should have unassigned users as options in the user select" do
    page.should have_xpath "//select[@id = 'event_organizer_user_id']/option[@value = #{@user1.id.to_s}]"
  end

  it "should assign the selected user as an organizer and display the name and email" do
    user_to_assign = find("option[#{@user1.id.to_s}]")
    select(user_to_assign.text, :from =>'event_organizer_user_id')

    click_button "Assign"

    page.should have_content("user1@mail.com")
    page.should have_content("Joe Cairo")
  end

  it "should assign the selected user as an organizer and remove the selected user from the user select options" do
    user_to_assign = find("option[#{@user1.id.to_s}]")
    select(user_to_assign.text, :from =>'event_organizer_user_id')

    click_button "Assign"

    page.should_not have_xpath "//select[@id = 'event_organizer_user_id']/option[@value = #{@user1.id.to_s}]"
  end

  it "should remove the organizer the table of organizers" do
    @event.organizers << @user1
    visit "/events/#{@event.id}/organizers"

    page.should have_content("user1@mail.com")
    page.should have_selector('input[value="Remove"]')

    click_button "Remove"

    page.should_not have_content("user1@mail.com")
    page.should_not have_selector('input[value="Remove"]')
  end

  it "should remove the organizer and display the removed organizer int the user select" do
    @event.organizers << @user1
    visit "/events/#{@event.id}/organizers"

    click_button "Remove"

    removed_user = find("option[#{@user1.id.to_s}]")
    removed_user.value.should eq(@user1.id.to_s)
    removed_user.text.should eq(@user1.full_name)
  end
end