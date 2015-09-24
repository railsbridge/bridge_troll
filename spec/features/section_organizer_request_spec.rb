require 'rails_helper'

describe "the section organizer tool", js: true do
  before do
    @organizer = create(:user)
    @student = create(:user)
    @volunteer = create(:user)
    @waitlisted = create(:user)

    @event = create(:event)
    @event.organizers << @organizer
    create(:student_rsvp, user: @student, event: @event)
    create(:volunteer_rsvp, user: @volunteer, event: @event)
    create(:student_rsvp, waitlist_position: 1, user: @waitlisted, event: @event)

    sign_in_as(@organizer)
  end

  it "allows the organizer to view attendees and assign them to sections" do
    visit event_organize_sections_path(@event)
    within '#section-organizer' do
      expect(page).to have_content(@student.full_name)
      expect(page).to have_content(@volunteer.full_name)
      expect(page).not_to have_content(@waitlisted.full_name)
    end

    visit event_organize_sections_path(@event)
    expect(page).to have_css('.bridgetroll-section', count: 1)
    click_button 'Add Section'
    expect(page).to have_css('.bridgetroll-section', count: 2)
  end
end
