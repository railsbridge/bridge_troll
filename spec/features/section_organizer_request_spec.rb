require 'spec_helper'

describe "the section organizer tool" do
  before do
    @organizer = create(:user)
    @student = create(:user)

    @event = create(:event)
    @event.organizers << @organizer
    create(:student_rsvp, user: @student, event: @event)

    sign_in_as(@organizer)
  end

  it "should show the names of all students", js: true do
    visit organize_sections_event_path(@event)
    within '#section-organizer' do
      page.should have_content(@student.full_name)
    end
  end
end
