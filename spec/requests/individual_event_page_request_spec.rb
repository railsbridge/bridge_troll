require 'spec_helper'

def add_volunteer_to_event(event, attributes)
  user = create(:user)
  user.profile.update_attributes!(attributes)
  create(:rsvp, :user => user, :event => event)
end

describe "the individual event page" do
  before do
    @event = create(:event)
  end
  
  context "user is not logged in" do
    it "shows a list of volunteers for the event" do
      user1 = create(:user)
      user2 = create(:user)
      create(:rsvp, :user => user1, :event => @event)
      visit event_path(@event)

      page.should have_content("Volunteers")
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

    it "does not display the Manage Organizers link or Edit link" do
      visit event_path(@event)
      page.should_not have_content("Manage Organizers")
      page.should_not have_content("Edit")
    end
  end

  context "user is logged in but is not an organizer for the event" do
    before do
      sign_in_as(create(:user))
    end

    it "does not display the Manage Organizers link or Edit link" do
      visit event_path(@event)
      page.should_not have_content("Manage Organizers")
      page.should_not have_content("Edit")
    end

    it "doesn't display sensitive volunteer information" do
      rsvp = create(:rsvp, event: @event)
      volunteer = rsvp.user
      volunteer.update_attributes!(hacking: true, teaching: true)

      visit event_path(@event)
      page.should have_content(volunteer.full_name)

      page.should_not have_content(volunteer.email)
      page.should_not have_content("Willing to Teach:")
      page.should_not have_content("Willing to TA:")
      page.should_not have_content("Willing to Teach or TA")
      page.should_not have_content("Not Interested in Teaching")
    end
  end

  context "user is logged in and is an organizer of the event" do
    before do
      user = create(:user)
      @event.organizers << user
      sign_in_as(user)
    end

    it "lets the user manage organizers" do
      visit event_path(@event)
      click_link "Manage Organizers"
      page.should have_content("Organizer Assignment")
    end

    it "lets the user edit the event" do
      visit event_path(@event)
      click_link "Edit"
      fill_in "Title", with: "New totally awesome event"
      click_button "Update Event"

      visit event_path(@event)
      page.should have_content "New totally awesome event"
    end

    it "shows all volunteer information" do
      4.times { add_volunteer_to_event(@event, hacking: true, teaching: true) }
      3.times { add_volunteer_to_event(@event, hacking: true, taing: true) }
      2.times { add_volunteer_to_event(@event, hacking: true, teaching: true, taing: true) }
      1.times { add_volunteer_to_event(@event, hacking: true) }

      volunteer = create(:user)
      volunteer.profile.update_attributes!(hacking: true, teaching: true)
      create(:rsvp, user: volunteer, event: @event)

      visit event_path(@event)
      page.should have_content(volunteer.email)
      page.should have_content(volunteer.full_name)
      page.should have_content("#{volunteer.full_name} - #{volunteer.email}")

      page.should have_content("Willing to Teach: 5")
      page.should have_content("Willing to TA: 3")
      page.should have_content("Willing to Teach or TA: 2")
      page.should have_content("Not Interested in Teaching: 1")
      page.should have_content("All Volunteers: 11")

      page.should have_css('.teach', count: 5)
      page.should have_css('.ta', count: 3)
      page.should have_css('.both', count: 2)
      page.should have_css('.none', count: 1)
    end
  end

  context "user is logged in and is an admin" do
    before do
      sign_in_as(create(:user, admin: true))
      visit event_path(@event)
    end

    it "lets the user manage organizers" do
      click_link "Manage Organizers"
      page.should have_content("Organizer Assignment")
    end

    it "lets the user edit the event" do
      click_link "Edit"
      fill_in "Title", with: "New totally awesome event"
      click_button "Update Event"

      visit event_path(@event)
      page.should have_content "New totally awesome event"
    end

    it "shows all volunteer information" do
      4.times { add_volunteer_to_event(@event, hacking: true, teaching: true) }
      3.times { add_volunteer_to_event(@event, hacking: true, taing: true) }
      2.times { add_volunteer_to_event(@event, hacking: true, teaching: true, taing: true) }
      1.times { add_volunteer_to_event(@event, hacking: true) }

      volunteer = create(:user)
      volunteer.profile.update_attributes!(hacking: true, teaching: true)
      create(:rsvp, user: volunteer, event: @event)

      visit event_path(@event)
      page.should have_content(volunteer.email)
      page.should have_content(volunteer.full_name)
      page.should have_content("#{volunteer.full_name} - #{volunteer.email}")

      page.should have_content("Willing to Teach: 5")
      page.should have_content("Willing to TA: 3")
      page.should have_content("Willing to Teach or TA: 2")
      page.should have_content("Not Interested in Teaching: 1")
      page.should have_content("All Volunteers: 11")

      page.should have_css('.teach', count: 5)
      page.should have_css('.ta', count: 3)
      page.should have_css('.both', count: 2)
      page.should have_css('.none', count: 1)
    end
  end
end
