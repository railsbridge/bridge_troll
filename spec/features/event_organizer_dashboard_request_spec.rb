require 'rails_helper'

describe "the organizer dashboard" do
  before do
    @organizer = create(:user)
    @event = create(:event, :title => 'RailsBridge for Dik Diks')
    @event.organizers << @organizer
    sign_in_as(@organizer)
  end

  it "should have a page" do
    visit event_organizer_tools_path(@event)
    page.should have_content('RailsBridge for Dik Diks')
  end

  it "lets the user manage organizers" do
    visit event_organizer_tools_path(@event)
    click_link "Manage Organizers"
    page.should have_content("Organizer Assignment")
  end

  it "lets the user preview the student RSVP page" do
    visit event_organizer_tools_path(@event)
    click_link "Preview Student RSVP Form"
    page.should have_content("Operating System")
  end

  it "lets the user preview the student RSVP page" do
    visit event_organizer_tools_path(@event)
    click_link "Preview Volunteer RSVP Form"
    page.should have_content("Volunteer Preferences")
  end

  it "lets the user assign students and volunteers to sections" do
    visit event_organizer_tools_path(@event)
    click_link "Arrange Class Sections"
    page.should have_content("Section Organizer")
  end

  it "lets the user review sent emails" do
    @email = @event.event_emails.create(
      subject: 'Hello, Attendees!',
      body: 'The event will be fun!',
      sender: @organizer
    )

    visit new_event_email_path(@event)
    page.should have_content(@email.subject)
    page.should have_content(@email.body)

    click_link @email.body
    page.should have_content(@email.subject)
    page.should have_content(@email.body)
  end

  it 'lets the user download a CSV of student rsvps' do
    visit event_organizer_tools_path(@event)
    click_link 'Show all Attendee RSVP Details'

    click_link 'Download Student Details CSV'

    csv_contents = page.source
    csv_contents.should include("Student Name")
    csv_contents.should include("Class Level")
    csv_contents.should include("Operating System")
    csv_contents.should include("Occupation")
  end

  it "lets the user check in attendees", js: true do
    user1 = create(:user, first_name: 'Anthony')
    user2 = create(:user, first_name: 'Bapp')

    session1 = @event.event_sessions.first
    session1.update_attribute(:name, 'Installfest')
    session2 = create(:event_session, event: @event, name: 'Curriculum')

    rsvp1 = create(:rsvp, user: user1, event: @event)
    rsvp2 = create(:rsvp, user: user2, event: @event)

    rsvp_session1 = create(:rsvp_session, rsvp: rsvp1, event_session: session1)
    rsvp_session2 = create(:rsvp_session, rsvp: rsvp2, event_session: session1)

    visit event_organizer_tools_path(@event)

    page.should have_content("Check in for Installfest")
    page.should have_content("Check in for Curriculum")

    click_link("Check in for Installfest")
    page.should have_content(user1.first_name)

    within "#rsvp_session_#{rsvp_session1.id}" do
      within '.create' do
        click_on 'Check In'
      end
      page.should have_content('Checked In!')
    end

    within '.checkin-counts' do
      page.should have_content("1")
    end

    rsvp_session1.reload.should be_checked_in
    rsvp_session2.reload.should_not be_checked_in

    within "#rsvp_session_#{rsvp_session2.id}" do
      within '.create' do
        click_on 'Check In'
      end
      page.should have_content('Checked In!')
    end

    within '.checkin-counts' do
      page.should have_content("2")
    end

    rsvp_session1.reload.should be_checked_in
    rsvp_session2.reload.should be_checked_in

    visit event_event_session_checkins_path(@event, session1)

    within "#rsvp_session_#{rsvp_session1.id}" do
      page.should have_content 'Checked In'
    end
    within "#rsvp_session_#{rsvp_session2.id}" do
      page.should have_content 'Checked In'
    end

    within "#rsvp_session_#{rsvp_session1.id}" do
      within '.destroy' do
        click_on 'Un-Check In'
      end
      page.should_not have_content 'Saving'
    end

    within '.checkin-counts' do
      page.should have_content("1")
    end

    rsvp_session1.reload.should_not be_checked_in
  end
end
