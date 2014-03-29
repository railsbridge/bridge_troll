require 'spec_helper'

describe "arranging sections for an event", js: true do
  before do
    @event = create(:event)
    create(:event_session, event: @event)
    @event.reload.event_sessions.count.should == 2

    @session1, @session2 = @event.event_sessions.all

    @session1_rsvp = create(:student_rsvp, event: @event, class_level: 1)
    @session1_rsvp.rsvp_sessions.create(event_session: @session1, checked_in: true)
    @session1_rsvp.rsvp_sessions.create(event_session: @session2, checked_in: false)

    @session2_rsvp = create(:student_rsvp, event: @event, class_level: 2)
    @session2_rsvp.rsvp_sessions.create(event_session: @session1, checked_in: false)
    @session2_rsvp.rsvp_sessions.create(event_session: @session2, checked_in: true)

    @both_rsvp = create(:student_rsvp, event: @event, class_level: 3)
    @both_rsvp.rsvp_sessions.create(event_session: @session1, checked_in: true)
    @both_rsvp.rsvp_sessions.create(event_session: @session2, checked_in: true)

    @neither_attendee = create(:student_rsvp, event: @event, class_level: 4)
    @neither_attendee.rsvp_sessions.create(event_session: @session1, checked_in: false)
    @neither_attendee.rsvp_sessions.create(event_session: @session2, checked_in: false)

    @user_organizer = create(:user)
    @event.organizers << @user_organizer
    sign_in_as @user_organizer
  end

  it "groups the attendees by their chosen level" do
    visit organize_sections_event_path(@event)

    page.should have_css('.auto-assign-reminder')

    within '#section-organizer' do
      click_on "Auto-Arrange"
    end

    within '.modal.auto-arrange-choices' do
      page.find("[value='#{@session1.id}']").click
      click_on "Auto-Arrange"
    end

    page.should_not have_css('.auto-assign-reminder')

    within '.bridgetroll-section-level.level1' do
      page.should have_content(@session1_rsvp.user.full_name)
    end

    within '.bridgetroll-section-level.level3' do
      page.should have_content(@both_rsvp.user.full_name)
    end

    counts = (1..5).map do |level|
      page.all(".bridgetroll-section-level.level#{level} .bridgetroll-section").length
    end
    counts.should == [1, 0, 1, 0, 0]
  end
end
