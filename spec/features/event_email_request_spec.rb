require 'rails_helper'

RSpec.describe 'Sending an event email', js: true do
  let(:recipients) do
    JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to']
  end
  let!(:event) { FactoryGirl.create(:event, student_rsvp_limit: 1) }
  let(:organizer) { FactoryGirl.create(:user) }

  before do
    FactoryGirl.create(:rsvp, user: organizer, event: event, role: Role::ORGANIZER)

    no_show_volunteer = FactoryGirl.create(:user)
    FactoryGirl.create(:volunteer_rsvp, user: no_show_volunteer, event: event)

    reliable_volunteer = FactoryGirl.create(:user, first_name: 'Sheila', last_name: 'Cool')
    reliable_rsvp = FactoryGirl.create(:volunteer_rsvp, user: reliable_volunteer, event: event)
    reliable_rsvp.rsvp_sessions.first.update(checked_in: true)

    accepted_student = FactoryGirl.create(:user, first_name: 'Mark', last_name: 'Mywords')
    FactoryGirl.create(:student_rsvp, user: accepted_student, event: event)

    waitlisted_student = FactoryGirl.create(:user)
    FactoryGirl.create(:student_rsvp, user: waitlisted_student, event: event, waitlist_position: 1)

    FactoryGirl.create(:user, email: 'unrelated_user@example.com')

    sign_in_as(organizer)
    visit event_organizer_tools_path(event)
    click_link 'Email Attendees'
  end

  it 'should show an accurate count of the # of people to be emailed when clicking buttons' do
    click_button 'Add'
    find('#recipients-add-volunteers').click
    expect(page).to have_content('2 people')

    click_button 'Add'
    find('#recipients-add-accepted-students').click
    expect(page).to have_content('3 people')

    click_button 'Add'
    find('#recipients-add-all').click
    expect(page).to have_content('4 people')

    click_button 'Remove'
    find('#recipients-remove-all').click
    expect(page).to have_content('0 people')

    click_button 'Add'
    find('#recipients-add-waitlisted-students').click
    expect(page).to have_content('1 person')

    click_button 'Add'
    find('#recipients-add-all').click
    click_button 'Remove'
    find('#recipients-remove-no-shows').click
    expect(page).to have_content('1 person')
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

  it 'should have a "CC Organizers" checkbox' do
    expect(page).to have_unchecked_field('CC Organizers')
  end

  it "should show an accurate count of the # of cc'd recipients when selecting cc checkboxes" do
    expect(page).to_not have_content ('1 event organizer')

    check 'CC Organizers'
    expect(page).to have_content ('1 event organizer')
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
