require 'rails_helper'

describe "Announcing an event" do
  before do
    @location = create(:location, name: 'Carbon Nine')
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    @admin = create(:user, admin: true)

    sign_in_as(@user_organizer)

    visit "/events/new"
    fill_in_good_event_details
    fill_in 'Title', with: "A title"
    fill_in 'What population is this workshop reaching out to?', with: "a population"
    fill_in 'event_target_audience', :with => "women"
    page.select 'Carbon Nine', :from => 'Location'
    check("coc")
  end

  context "automatically" do

    context "before approval" do
      it "the announcement email can not be sent by an organizer" do
        choose('event_email_on_approval_true')
        click_on 'Submit Event For Approval'
        click_on "Organizer Console"
        click_on "Send Announcement Email"
        expect(page).to have_content 'announcement email was not sent'
      end
    end

    context "after approval" do
      it "the announcement can not be resent by an organizer" do
        choose('event_email_on_approval_true')
        click_on 'Submit Event For Approval'

        sign_in_as @admin
        visit unpublished_events_path
        click_on "Publish"

        sign_in_as(@user_organizer)
        visit '/'
        click_on "A title"
        click_on "Organizer Console"
        click_on "Send Announcement Email"
        expect(page).to have_content 'announcement email was not sent'
      end
    end
  end

  context "manually" do
    it "the announcement is sent when organizer chooses" do
      choose('event_email_on_approval_false')
      click_on 'Submit Event For Approval'

      sign_in_as @admin
      visit unpublished_events_path
      click_on "Publish"

      sign_in_as(@user_organizer)
      visit '/'
      click_on "A title"
      click_on "Organizer Console"
      click_on "Send Announcement Email"
      expect(page).to have_content 'announcement email was sent'
    end

    it "the announcement email is not sent after organizer has already sent the email" do
      choose('event_email_on_approval_false')
      click_on 'Submit Event For Approval'

      sign_in_as @admin
      visit unpublished_events_path
      click_on "Publish"

      sign_in_as(@user_organizer)
      visit '/'
      click_on "A title"
      click_on "Organizer Console"
      click_on "Send Announcement Email"
      click_on "Send Announcement Email"
      expect(page).to have_content 'announcement email was not sent'
    end
  end
end
