require 'rails_helper'

describe 'External Event' do
  let(:admin_user) { create(:user, admin: true) }
  let!(:region) { create(:region) }
  let!(:chapter) { create(:chapter) }

  before do
    sign_in_as(admin_user)
  end

  it "can create a new external event" do
    visit external_events_path
    click_link "New External Event"

    select region.name, from: "external_event_region_id"
    select chapter.name, from: "external_event_chapter_id"

    fill_in "Name", with: "Interesting External Event"
    fill_in "URL", with: "http://example.com/event"
    fill_in "City", with: "San Francisco"
    fill_in "Location", with: "Tonga Room"
    fill_in "Organizers", with: "Ham Sandwich and Cheese Fries"

    click_button "Create External event"

    expect(ExternalEvent.last.region).to eq(region)

    expect(page).to have_content("Interesting External Event")

    visit region_path(region)

    expect(page).to have_content("Interesting External Event")
    expect(ExternalEvent.last.chapter).to eq(chapter)
  end
end
