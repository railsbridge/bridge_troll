require 'rails_helper'

describe "Edit Event" do
  before do
    @user_organizer = create(:user, email: "organizer@mail.com", first_name: "Sam", last_name: "Spade")
    @drafted_event = create(:event, title: 'draft title', draft_saved: true, published: false)
    @drafted_event.organizers << @user_organizer

    expect(@drafted_event.current_state).to eq :draft_saved
    sign_in_as(@user_organizer)
    visit edit_event_path(@drafted_event)
  end

  context 'event saved previously as draft' do
    it 'allows a draft to be saved' do
      fill_in 'Title', with: 'real title'
      check("coc")
      click_on 'Submit Event For Approval'

      expect(page).to have_content('Event was successfully updated')
      expect(page).to have_content('real title')

      expect(page.current_path).to eq event_path(@drafted_event)
      expect(Event.find(@drafted_event.id).current_state).to eq :pending_approval
    end
  end
end
