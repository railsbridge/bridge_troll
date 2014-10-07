require 'rails_helper'

describe "the section organizer tool" do
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

  it "should show the names of all students not on the waitlist", js: true do
    visit event_organize_sections_path(@event)
    within '#section-organizer' do
      page.should have_content(@student.full_name)
      page.should have_content(@volunteer.full_name)
      page.should_not have_content(@waitlisted.full_name)
    end
  end

  it "allows the organizer to add a new section", js: true do
    visit event_organize_sections_path(@event)
    page.should_not have_content('New Section')
    click_button 'Add Section'
    page.should have_content('New Section')
  end
end
