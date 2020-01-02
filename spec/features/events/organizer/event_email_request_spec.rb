# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sending an event email', js: true do
  let(:recipients) do
    JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to']
  end
  let!(:event) { FactoryBot.create(:event, student_rsvp_limit: 1) }
  let(:organizer) { FactoryBot.create(:user) }

  def choose_dropdown_option(dropdown_name, dropdown_option)
    click_button dropdown_name
    within "#recipients-#{dropdown_name.downcase}-dropdown" do
      click_on(dropdown_option)
    end
  end

  before do
    FactoryBot.create(:rsvp, user: organizer, event: event, role: Role::ORGANIZER)

    no_show_volunteer = FactoryBot.create(:user)
    FactoryBot.create(:volunteer_rsvp, user: no_show_volunteer, event: event)

    reliable_volunteer = FactoryBot.create(:user, first_name: 'Sheila', last_name: 'Cool')
    reliable_rsvp = FactoryBot.create(:volunteer_rsvp, user: reliable_volunteer, event: event)
    reliable_rsvp.rsvp_sessions.first.update(checked_in: true)

    accepted_student = FactoryBot.create(:user, first_name: 'Mark', last_name: 'Mywords')
    FactoryBot.create(:student_rsvp, user: accepted_student, event: event)

    waitlisted_student = FactoryBot.create(:user)
    FactoryBot.create(:student_rsvp, user: waitlisted_student, event: event, waitlist_position: 1)

    FactoryBot.create(:user, email: 'unrelated_user@example.com')

    sign_in_as(organizer)
    visit event_organizer_tools_path(event)
    click_link 'Email Attendees'
  end

  it 'shows an accurate count of the # of people to be emailed when clicking buttons' do
    choose_dropdown_option('Add', 'Volunteers')
    expect(page).to have_content('2 people')

    choose_dropdown_option('Add', 'Accepted Students')
    expect(page).to have_content('3 people')

    choose_dropdown_option('Add', 'All')
    expect(page).to have_content('4 people')

    choose_dropdown_option('Remove', 'All')
    expect(page).to have_content('0 people')

    choose_dropdown_option('Add', 'Waitlisted Students')
    expect(page).to have_content('1 person')

    choose_dropdown_option('Add', 'All')
    choose_dropdown_option('Remove', 'No-shows')
    expect(page).to have_content('1 person')
  end

  it 'preserves form fields on error' do
    choose_dropdown_option('Add', 'Volunteers')
    expect(page).to have_content('2 people')

    body_text = 'Hello, attendees'
    fill_in 'Body', with: body_text
    expect(page).to have_content 'This email will be sent to you and 2 people.'

    click_button 'Send Email'
    expect(page).to have_content('We were unable to send your email')
    expect(find_field('Body').value).to eq(body_text)
    expect(page).to have_content('2 people')

    selected_user_ids = page.all('select[name="event_email[recipients][]"] option[selected]').map(&:value).map(&:to_i)
    expect(selected_user_ids).to match_array(event.volunteer_rsvps.map { |r| r.user.id })
  end

  it 'sends an email to the selected people' do
    click_button 'Add'
    find('#recipients-add-all').click
    fill_in 'Subject', with: 'Hello, Railsbridgers'
    fill_in 'Body', with: 'This is a cool email body!'
    click_button 'Send Email'

    expect(page).to have_content 'Your email has been sent'
    # includes current user organizer
    expect(recipients.length).to eq 5
  end

  it 'lets organizers send emails to individuals' do
    find('select.select2-hidden-accessible').select('Sheila Cool')
    find('select.select2-hidden-accessible').select('Mark Mywords')
    fill_in 'Subject', with: 'Hello, Railsbridge Friends'
    fill_in 'Body', with: "Y'all are so cool!"
    expect(page).to have_content 'This email will be sent to you and 2 people.'

    click_button 'Send Email'
    expect(page).to have_content 'Your email has been sent'
    expect(recipients.length).to eq(3)
  end

  it 'has a "CC Organizers" checkbox' do
    expect(page).to have_unchecked_field('CC Organizers')
  end

  it "shows an accurate count of the # of cc'd recipients when selecting cc checkboxes" do
    expect(page).not_to have_content('1 event organizer')

    check 'CC Organizers'
    expect(page).to have_content('1 event organizer')
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
end
