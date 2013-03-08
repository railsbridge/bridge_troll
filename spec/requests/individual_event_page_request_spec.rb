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

    it "does not display the event public email" do
      visit event_path(@event)
      page.should_not have_content("public_email@example.org")
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

    it "displays the event public email" do
      visit event_path(@event)
      page.should have_content("public_email@example.org")
    end

    it "doesn't display sensitive volunteer information" do
      volunteer = create(:user)
      rsvp = create(:rsvp, user: volunteer, event: @event, teaching: true)

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

    it "lets the user manage volunteers" do
      visit event_path(@event)
      click_link "Manage Volunteers"
      page.should have_content("Volunteer Assignment")
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
      4.times { create(:rsvp, event: @event, teaching: true) }
      3.times { create(:rsvp, event: @event, taing: true) }
      2.times { create(:rsvp, event: @event, teaching: true, taing: true) }
      1.times { create(:rsvp, event: @event) }

      volunteer = create(:user)
      create(:rsvp, user: volunteer, event: @event, teaching: true)

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

    it "lets the user check in volunteers", js: true do
      user1 = create(:user, first_name: 'Anthony')
      user2 = create(:user, first_name: 'Bapp')

      session1 = @event.event_sessions.first
      session1.update_attribute(:name, 'Installfest')
      session2 = create(:event_session, event: @event, name: 'Curriculum')

      rsvp1 = create(:rsvp, user: user1, event: @event)
      rsvp2 = create(:rsvp, user: user2, event: @event)

      rsvp_session1 = create(:rsvp_session, rsvp: rsvp1, event_session: session1)
      rsvp_session2 = create(:rsvp_session, rsvp: rsvp2, event_session: session1)

      visit event_path(@event)
      page.should have_content("Check in for Installfest")
      page.should have_content("Check in for Curriculum")

      click_link("Check in for Installfest")
      page.should have_content(user1.first_name)

      within "#edit_rsvp_session_#{rsvp_session1.id}" do
        click_on 'Check In'
        page.should have_content('Checked In!')
      end

      rsvp_session1.reload.should be_checked_in
      rsvp_session2.reload.should_not be_checked_in

      within "#edit_rsvp_session_#{rsvp_session2.id}" do
        click_on 'Check In'
        page.should have_content('Checked In!')
      end

      rsvp_session1.reload.should be_checked_in
      rsvp_session2.reload.should be_checked_in

      visit event_event_session_checkins_path(@event, session1)

      within "#edit_rsvp_session_#{rsvp_session1.id}" do
        page.should have_content 'Checked In'
      end
      within "#edit_rsvp_session_#{rsvp_session2.id}" do
        page.should have_content 'Checked In'
      end
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
      4.times { create(:rsvp, event: @event, teaching: true) }
      3.times { create(:rsvp, event: @event, taing: true) }
      2.times { create(:rsvp, event: @event, teaching: true, taing: true) }
      1.times { create(:rsvp, event: @event) }

      volunteer = create(:user)
      create(:rsvp, user: volunteer, event: @event, teaching: true)

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
