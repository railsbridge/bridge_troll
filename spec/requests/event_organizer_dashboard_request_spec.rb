require 'spec_helper'

describe "the organizer dashboard" do
  before do
    @organizer = create(:user)
    @event = create(:event, :title => 'RailsBridge for Dik Diks')
    @event.organizers << @organizer
    sign_in_as(@organizer)
  end

  it "should have a page" do
    visit organize_event_path(@event)
    page.should have_content('RailsBridge for Dik Diks')
  end

  it "lets the user manage organizers" do
    visit organize_event_path(@event)
    click_link "Manage Organizers"
    page.should have_content("Organizer Assignment")
  end

  it "lets the user manage volunteers" do
    visit organize_event_path(@event)
    click_link "Manage Volunteers"
    page.should have_content("Volunteer Assignment")
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

    visit organize_event_path(@event)

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