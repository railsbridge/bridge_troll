require 'rails_helper'

describe 'attendee views class section' do

    it 'shows the class level and room on the upcoming events page' do

      chapter = create(:chapter)
      @event = create(:event, chapter: chapter)
      @user = create(:user)
      sign_in_as @user

      visit volunteer_new_event_rsvp_path(@event)

      fill_in "rsvp_subject_experience", with: "asdfasdfasdfasd"
      fill_in "rsvp_teaching_experience", with: "asdfasdfasdfasd"
      choose Course.find_by_name('RAILS').levels[0][:title]

      check('coc')
      click_on 'Submit'

      #save_and_open_page

      section = @event.sections.create(name: "room A", class_level: 2)
      rsvp = @user.rsvps.find_by(event: @event)
      rsvp.update_attribute(:section_id, section.id)
      visit(root_path)

      expect(page).to have_content("room A")
      expect(page).to have_content("orange")
    end

end
