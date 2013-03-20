require 'spec_helper'

describe "the individual event page" do
  before do
    @event = create(:event, :public_email => "public_email@example.org")
  end
  
  context "user is not logged in" do
    it "shows a list of volunteers for the event" do
      user1 = create(:user)
      user2 = create(:user)
      create(:rsvp, :user => user1, :event => @event)
      visit event_path(@event)

      page.should have_content(user1.full_name)
      page.should_not have_content(user2.full_name)
    end

    it "shows who is organizing the event" do
      visit event_path(@event)
      within(".organizers") do
        page.should have_content("No Organizer Assigned")
      end

      user1 = create(:user)
      user2 = create(:user)
      @event.organizers << user1
      @event.organizers << user2

      visit event_path(@event)
      within(".organizers") do
        page.should have_content(user1.full_name)
        page.should have_content(user2.full_name)
      end
    end

    it "does not display the Edit link" do
      visit event_path(@event)
      page.should_not have_content("Edit")
    end

    it "does not display the event public email" do
      visit event_path(@event)
      page.should_not have_content("public_email@example.org")
    end
  end

  context "user is logged in but is not an organizer for the event" do
    before do
      sign_in_as(create(:user))
    end

    it "does not display the Edit link" do
      visit event_path(@event)
      page.should_not have_content("Edit")
    end

    it "displays the event public email" do
      visit event_path(@event)
      page.should have_content("public_email@example.org")
    end
  end

  context "user is logged in and is an organizer of the event" do
    before do
      user = create(:user)
      @event.organizers << user
      sign_in_as(user)
    end

    it "lets the user edit the event" do
      visit event_path(@event)
      click_link "Edit"
      fill_in "Title", with: "New totally awesome event"
      click_button "Update Event"

      visit event_path(@event)
      page.should have_content "New totally awesome event"
    end
  end
end
