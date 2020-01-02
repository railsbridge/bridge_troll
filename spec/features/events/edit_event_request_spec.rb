# frozen_string_literal: true

require 'rails_helper'

describe 'Edit Event' do
  before do
    @user_organizer = create(:user, email: 'organizer@mail.com', first_name: 'Sam', last_name: 'Spade')
    @drafted_event = create(:event, title: 'draft title', current_state: :draft)
    @drafted_event.organizers << @user_organizer

    expect(@drafted_event).to be_draft
    sign_in_as(@user_organizer)
    visit edit_event_path(@drafted_event)
  end

  context 'event saved previously as draft' do
    it 'allows a draft to be saved' do
      fill_in 'Title', with: 'real title'
      check('coc')
      click_on 'Submit Event For Approval'

      expect(page).to have_content('Event was successfully updated')
      expect(page).to have_content('real title')

      expect(page).to have_current_path event_path(@drafted_event), ignore_query: true
      expect(Event.find(@drafted_event.id)).to be_pending_approval
    end
  end
end
