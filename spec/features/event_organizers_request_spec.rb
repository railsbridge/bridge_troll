require 'spec_helper'

describe "Event Organizers page" do
  before do
    @user_organizer = create(:user, email: "orgainzer@mail.com", first_name: "Sam", last_name: "Spade")
    @user1 = create(:user, email: "user1@mail.com", first_name: "Joe", last_name: "Cairo")

    @event = create(:event)
    @event.organizers << @user_organizer

    sign_in_as(@user_organizer)
  end

  it "displays the existing organizers name and email address" do
    visit "/events/#{@event.id}/organizers"

    page.should have_content("Organizer Assignments")
    page.should have_content("orgainzer@mail.com")
    page.should have_content("Sam Spade")
  end

  it "allows an organizer to assign another user as an organizer" do
    visit "/events/#{@event.id}/organizers"

    page.should have_select('event_organizer[user_id]', options: ['', @user1.full_name])

    select(@user1.full_name, :from =>'event_organizer_user_id')

    click_button "Assign"

    page.should have_content("user1@mail.com")
    page.should have_content("Joe Cairo")
    page.should have_select('event_organizer[user_id]', options: [''])
  end

  describe "removing an organizer" do
    before do
      @event.organizers << @user1
    end

    it "allows an organizer to remove another user from the list of organizers" do
      visit "/events/#{@event.id}/organizers"

      page.should have_content("user1@mail.com")
      page.should have_selector('input[value="Remove"]')

      page.should have_select('event_organizer[user_id]', options: [''])

      click_button "Remove"

      page.should_not have_content("user1@mail.com")
      page.should_not have_selector('input[value="Remove"]')

      page.should have_select('event_organizer[user_id]', options: ['', @user1.full_name])
    end
  end
end
