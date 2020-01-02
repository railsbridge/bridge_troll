# frozen_string_literal: true

require 'rails_helper'

describe 'the approval page' do
  before do
    @event = create(:event, title: 'Exciting event', current_state: :pending_approval)
    @event.organizers << create(:user)

    @spammer = create(:user)
    @spam_event = create(:event, title: 'Spammy Event', current_state: :pending_approval)
    @spam_event.organizers << @spammer

    @admin = create(:user, admin: true)
    sign_in_as(@admin)
  end

  describe 'publishing an event' do
    it 'removes it from the unpublished events page' do
      visit unpublished_events_path

      expect(page).to have_css('.event-card', count: 2)

      within ".event-#{@event.id}" do
        click_on 'Publish'
      end

      within '.header-container' do
        expect(page).to have_content(@event.title)
      end

      visit unpublished_events_path
      expect(page).to have_css('.event-card', count: 1)
    end
  end

  describe 'flagging an event as spam' do
    it 'removes it from the unpublished events page, marks as spam, and marks the organizer as a spammer' do
      visit unpublished_events_path

      expect(page).to have_css('.event-card', count: 2)

      within ".event-#{@spam_event.id}" do
        click_on 'Flag as Spam'
      end

      expect(page).to have_css('.event-card', count: 1)

      expect(@spam_event.reload).to be_spam
      expect(@spammer.reload).to be_spammer
    end
  end
end
