# frozen_string_literal: true

require 'rails_helper'

describe 'Announcing an event', :js do
  let(:user_organizer) { create(:user, email: 'organizer@mail.com', first_name: 'Sam', last_name: 'Spade') }
  let(:admin) { create(:user, admin: true) }
  let(:event_location) { create(:location) }
  let(:send_email_text) { 'Send Announcement Email' }

  before do
    create(:chapter)
    create(:course)
    sign_in_as(user_organizer)
    visit_new_events_form_and_expand_all_sections
    fill_in_good_event_details
    fill_in 'What population is this workshop reaching out to?', with: 'a population'
    check('coc')
  end

  context 'automatically' do
    before do
      choose('event_email_on_approval_true')
      click_on submit_for_approval_button
      expect(page).to have_content('Your event is awaiting approval')
      expect(Event.last).not_to be_nil
    end

    context 'before approval' do
      it 'does not allow the announcement email to be sent by an organizer' do
        click_on 'Organizer Console'
        expect(page).to have_no_content(send_email_text)
      end
    end

    context 'after approval' do
      before do
        Event.last.update_attribute(:location, event_location)

        sign_in_as admin
        visit unpublished_events_path
        accept_confirm { click_on 'Publish' }

        sign_in_as(user_organizer)
      end

      it 'does not allow the announcement to be resent by an organizer' do
        visit '/'
        click_on good_event_title
        click_on 'Organizer Console'
        expect(page).to have_no_content(send_email_text)
      end
    end
  end

  context 'manually' do
    before do
      choose('event_email_on_approval_false')
      click_on submit_for_approval_button
      expect(page).to have_content('Your event is awaiting approval')
      expect(Event.last).not_to be_nil
    end

    context 'before approval' do
      it 'does not allow the announcement email to be sent by an organizer' do
        click_on 'Organizer Console'
        expect(page).to have_no_content(send_email_text)
      end
    end

    context 'after approval' do
      before do
        Event.last.update_attribute(:location, event_location)

        sign_in_as admin
        visit unpublished_events_path
        accept_confirm do
          click_on 'Publish'
        end
      end

      it 'allows an organizer to send an announcement email' do
        expect(page).to have_content('This event has been published')

        sign_in_as(user_organizer)

        visit '/'
        click_on good_event_title
        click_on 'Organizer Console'
        accept_confirm { click_on send_email_text }
        expect(page).to have_content 'Your announcement email was sent!'
        expect(page).to have_no_content(send_email_text)
      end
    end
  end
end
