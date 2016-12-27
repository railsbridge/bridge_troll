require 'rails_helper'

describe "the attendee details modal", js: true do
  before do
    @organizer = create(:user)

    @event = create(:event)
    @event.organizers << @organizer
    @student_rsvp = create(:student_rsvp, user: create(:user), event: @event)

    sign_in_as(@organizer)

    visit event_organize_sections_path(@event)

    within 'ul.students' do
      find('i').click
    end
  end

  it "should list the student's operating system" do
    within '.modal-body' do
      expect(page).to have_content(@student_rsvp.operating_system_title)
    end
  end

  it "should list the student's class level title" do
    within '.modal-body' do
      expect(page).to have_content(@student_rsvp.level_title)
    end
  end

  it "it should list the student's job details" do
    within '.modal-body' do
      expect(page).to have_content(@student_rsvp.job_details)
    end
  end
end
