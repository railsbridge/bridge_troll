require 'rails_helper'

describe "the email page" do
  let(:recipients) { JSON.parse(ActionMailer::Base.deliveries.last.header['X-SMTPAPI'].to_s)['to'] }

  before do
    event = create(:event, student_rsvp_limit: 1)

    organizer = create(:user)
    create(:rsvp, user: organizer, event: event, role: Role::ORGANIZER)

    @vol1 = create(:user, email: 'vol1@email.com')
    create(:volunteer_rsvp, user: @vol1, event: event)

    @vol2 = create(:user, email: 'vol2@email.com')
    vol2_rsvp = create(:volunteer_rsvp, user: @vol2, event: event)
    vol2_rsvp.rsvp_sessions.first.update_attribute(:checked_in, true)

    @student = create(:user, email: 'student@email.com')
    create(:student_rsvp, user: @student, event: event)

    @waitlisted_student = create(:user, email: 'waitlisted@email.com')
    create(:student_rsvp, user: @waitlisted_student, event: event, waitlist_position: 1)

    create(:user, email: 'unrelated_user@example.com')

    sign_in_as(organizer)
    visit new_event_email_path(event)
  end

  it "should show an accurate count of the # of people to be emailed when selecting radio buttons", js: true do
    choose 'Only Volunteers'
    page.should have_content("2 people")

    choose 'Only Students'
    page.should have_content("1 person")

    choose 'All Attendees'
    page.should have_content("3 people")

    check 'Include waitlisted students'
    page.should have_content("4 people")

    check 'Only attendees who checked in'
    page.should have_content("1 person")
  end

  it "sends an email to the selected people" do
    choose 'All Attendees'
    fill_in 'Subject', with: 'Hello, Railsbridgers'
    fill_in 'Body', with: 'This is a cool email body!'
    click_button 'Send Mail'

    recipients.length.should == 4
  end
end
