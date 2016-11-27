require 'rails_helper'

describe "arranging sections for an event", js: true do
  before do
    @event = create(:event)
    create(:event_session, event: @event)
    expect(@event.reload.event_sessions.count).to eq(2)

    @session1, @session2 = @event.event_sessions.to_a

    @session1_rsvp = create(:student_rsvp, event: @event, class_level: 1, session_checkins: {@session1.id => true, @session2.id => false})

    @session2_rsvp = create(:student_rsvp, event: @event, class_level: 2, session_checkins: {@session1.id => false, @session2.id => true})

    @both_rsvp = create(:student_rsvp, event: @event, class_level: 3, session_checkins: {@session1.id => true, @session2.id => true})

    @neither_attendee = create(:student_rsvp, event: @event, class_level: 4, session_checkins: {@session1.id => false, @session2.id => false})

    @user_organizer = create(:user)
    @event.organizers << @user_organizer
    sign_in_as @user_organizer
  end

  it "groups the attendees by their chosen level" do
    visit event_organize_sections_path(@event)

    expect(page).to have_css('.auto-assign-reminder')

    within '#section-organizer' do
      click_on "Auto-Arrange"
    end

    within '.modal.auto-arrange-choices' do
      page.find("[value='#{@session1.id}']").click
      click_on "Auto-Arrange"
    end

    expect(page).not_to have_css('.auto-assign-reminder')

    within '.bridgetroll-section-level.level1' do
      expect(page).to have_content(@session1_rsvp.user.full_name)
    end

    within '.bridgetroll-section-level.level3' do
      expect(page).to have_content(@both_rsvp.user.full_name)
    end

    counts = (1..5).map do |level|
      page.all(".bridgetroll-section-level.level#{level} .bridgetroll-section").length
    end
    expect(counts).to eq([1, 0, 1, 0, 0])
  end
end
