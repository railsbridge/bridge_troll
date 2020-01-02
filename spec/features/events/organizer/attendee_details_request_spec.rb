# frozen_string_literal: true

require 'rails_helper'

describe 'the attendee details modal', js: true do
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

  it "lists the student's RSVP details" do
    within '.modal-body' do
      expect(page).to have_content(@student_rsvp.operating_system_title)
      expect(page).to have_content(@student_rsvp.level_title)
      expect(page).to have_content(@student_rsvp.job_details)
    end
  end
end
