require 'spec_helper'

describe "the event listing page" do
  it "listing should show blank Location if no location_id exists" do
    create(:location, :name => 'locname')
    event = create(:event, :location_id => nil, :title => 'mytitle')
    create(:event_session, event: event, starts_at: 1.day.from_now, ends_at: 2.days.from_now)

    visit events_path
    page.should have_content('Upcoming events')
  end

  it "listing should show formatted dates and times" do
    next_year = Time.now.year + 1
    event = build(:event_with_no_sessions,
                  location_id: nil,
                  title: 'mytitle2',
                  time_zone: 'Pacific Time (US & Canada)')
    event.event_sessions << create(:event_session,
                                   starts_at: Time.utc(next_year, 01, 31, 11, 20),
                                   ends_at: Time.utc(next_year, 01, 31, 11, 55))
    event.save!

    visit events_path
    page.should have_content("1/31/#{next_year}")
    page.should have_content('3:55 am PST')
  end

  it "allows a logged-in user to create a new event", js: true do
    sign_in_as(create(:user))
    visit events_path
    click_link "New Event"

    fill_in "Title", with: "February Event"

    click_link "Add a session"
    within ".event-sessions" do
      start_time_selects = all('.start_time')
      start_time_selects[0].select "2015"
      start_time_selects[1].select "January"
      start_time_selects[2].select "12"
      start_time_selects[3].select "03 PM"
      start_time_selects[4].select "15"

      end_time_selects = all('.end_time')
      end_time_selects[0].select "2015"
      end_time_selects[1].select "January"
      end_time_selects[2].select "12"
      end_time_selects[3].select "05 PM"
      end_time_selects[4].select "45"
    end

    select "Alaska", from: 'event_time_zone'
    fill_in "event_details", :with => "This is a note in the detail text box\n With a new line!"

    click_button "Create Event"

    page.should have_content("February Event")
    page.should have_content("This event currently has no location!")
    page.should have_content("This is a note in the detail text box")
    page.should have_css(".details p", text: 'With a new line!')

    visit events_path

    page.should have_content("February Event")
    page.should have_content("AKST") # alaska time code!
  end

  it "allows a logged-in user to volunteer for an event" do
    create(:event)
    user = create(:user)
    sign_in_as(user)

    visit events_path
    click_link("Volunteer")
    page.should have_content("almost signed up")
    fill_in "About you", :with => "I am cool and I use a Mac (but those two things are not related)"
    #TODO: add more fields
    click_button "Submit"
    page.should have_content("Thanks for volunteering")
  end
end