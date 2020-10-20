# frozen_string_literal: true

require 'rails_helper'

describe 'the organizer dashboard' do
  let(:organizer) { create(:user) }
  let(:event) { create(:event, title: 'RailsBridge for Dik Diks') }

  before do
    event.organizers << organizer
    sign_in_as(organizer)
  end

  it 'displays the event title' do
    visit event_organizer_tools_path(event)
    expect(page).to have_content('RailsBridge for Dik Diks')
  end

  it 'lets the user manage organizers' do
    visit event_organizer_tools_path(event)
    click_link 'Manage Organizers'
    expect(page).to have_content('Organizer Assignment')
  end

  it 'lets the user preview the student RSVP page' do
    visit event_organizer_tools_path(event)
    click_link 'Preview Student RSVP Form'
    expect(page).to have_content('Operating System')
  end

  it 'lets the user preview the volunteer RSVP page' do
    visit event_organizer_tools_path(event)
    click_link 'Preview Volunteer RSVP Form'
    expect(page).to have_content('Volunteer Preferences')
  end

  it 'lets the user assign students and volunteers to sections' do
    visit event_organizer_tools_path(event)
    click_link 'Arrange Class Sections'
    expect(page).to have_content('Section Organizer')
  end

  it 'lets the user review sent emails' do
    email = event.event_emails.create(
      subject: 'Hello, Attendees!',
      body: 'The event will be fun!',
      sender: organizer
    )

    visit new_event_email_path(event)
    expect(page).to have_content(email.subject)
    expect(page).to have_content(email.body)

    click_link email.body
    expect(page).to have_content(email.subject)
    expect(page).to have_content(email.body)
  end

  it 'lets the user download a CSV of student rsvps' do
    visit event_organizer_tools_path(event)
    click_link 'Show all Attendee RSVP Details'

    click_link 'Download basic student info'

    csv_contents = page.source
    expect(csv_contents).to include('Student Name')
    expect(csv_contents).to include('Class Level')
    expect(csv_contents).to include('Operating System')
    expect(csv_contents).to include('Occupation')
  end

  it 'lets the user check in attendees', js: true do
    user1 = create(:user, first_name: 'Anthony')
    user2 = create(:user, first_name: 'Bapp')

    session1 = event.event_sessions.first
    session1.update_attribute(:name, 'Installfest')
    # un-checked-in-session
    create(:event_session, event: event, name: 'Curriculum')

    rsvp1 = create(:rsvp, user: user1, event: event)
    rsvp2 = create(:rsvp, user: user2, event: event)

    rsvp_session1 = rsvp1.rsvp_sessions.first
    rsvp_session2 = rsvp2.rsvp_sessions.first

    visit event_organizer_tools_path(event)

    expect(page).to have_content('Check in for Installfest')
    expect(page).to have_content('Check in for Curriculum')

    click_link('Check in for Installfest')
    expect(page).to have_content(user1.first_name)

    within "#rsvp_session_#{rsvp_session1.id}" do
      within '.create' do
        click_on 'Check In'
      end
      expect(page).to have_content('Checked In!')
    end

    within '.checkin-counts' do
      expect(page).to have_content('1')
    end

    expect(rsvp_session1.reload).to be_checked_in
    expect(rsvp_session2.reload).not_to be_checked_in

    within "#rsvp_session_#{rsvp_session2.id}" do
      within '.create' do
        click_on 'Check In'
      end
      expect(page).to have_content('Checked In!')
    end

    within '.checkin-counts' do
      expect(page).to have_content('2')
    end

    expect(rsvp_session1.reload).to be_checked_in
    expect(rsvp_session2.reload).to be_checked_in

    visit event_event_session_checkins_path(event, session1)

    within "#rsvp_session_#{rsvp_session1.id}" do
      expect(page).to have_content 'Checked In'
    end
    within "#rsvp_session_#{rsvp_session2.id}" do
      expect(page).to have_content 'Checked In'
    end

    within "#rsvp_session_#{rsvp_session1.id}" do
      within '.destroy' do
        accept_confirm { click_on 'Un-Check In' }
      end
      expect(page).not_to have_content 'Saving'
    end

    within '.checkin-counts' do
      expect(page).to have_content('1')
    end

    expect(rsvp_session1.reload).not_to be_checked_in
  end

  it 'lets the organizer update the survey greeting' do
    visit event_organizer_tools_path(event)
    click_link 'Edit Email Body'
    fill_in 'Email Body:', with: 'Here is a fun survey'
    click_on 'Update'
    expect(event.reload.survey_greeting).to eq('Here is a fun survey')
  end
end
