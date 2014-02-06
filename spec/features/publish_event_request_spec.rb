require 'spec_helper'

describe "publishing an event" do
  before do
    @event = create(:event, title: "Exciting event", published: false)
    create(:event, title: "Spammy Event", published: false)

    @admin = create(:user, admin: true)
    sign_in_as(@admin)
  end

  it 'removes it from the unpublished events page' do
    visit unpublished_events_path

    page.should have_css('.event-card', count: 2)

    within ".event-#{@event.id}" do
      click_on "Publish"
    end

    within '.header-container' do
      page.should have_content(@event.title)
    end

    visit unpublished_events_path
    page.should have_css('.event-card', count: 1)
  end
end
