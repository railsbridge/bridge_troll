require 'spec_helper'

describe "the volunteer email page" do
  it "should show a list of the volunteers for an event" do
    event = create(:event, :location_id => nil, :title => 'Volunteer Magnet')
    create(:event_session, event: event, starts_at: 1.day.from_now, ends_at: 2.days.from_now)

    guy1 = create(:user, :email => 'guy1@email.com')
    guy2 = create(:user, :email => 'guy2@email.com')
    guy3 = create(:user, :email => 'guy3@email.com')

    volunteers = [guy1, guy2]
    event.volunteers = volunteers

    visit volunteer_emails_event_path(event)

    page.should have_content(guy1.email)
    page.should have_content(guy2.email)

    page.should_not have_content(guy3.email)
  end
end
