require 'spec_helper'

describe "the approval page" do
  before do
    @event = create(:event, title: "Exciting event", published: false)
    @event.organizers << create(:user)

    @spammer = create(:user)
    @spam_event = create(:event, title: "Spammy Event", published: false)
    @spam_event.organizers << @spammer

    @admin = create(:user, admin: true)
    sign_in_as(@admin)
  end

  describe "publishing an event" do
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

  describe "flagging an event as spam" do
    it 'removes it from the unpublished events page, marks as spam, and marks the organizer as a spammer' do
      visit unpublished_events_path

      page.should have_css('.event-card', count: 2)

      within ".event-#{@spam_event.id}" do
        click_on "Flag as Spam"
      end

      page.should have_css('.event-card', count: 1)

      @spam_event.reload.should be_spam
      @spammer.reload.should be_spammer
    end
  end
end
