require 'rails_helper'

describe "checking in attendees" do
  before do
    @event = create(:event)
    @event.event_sessions.first.update_attributes(name: 'Unique Session Name')
  end

  describe "as a normal user" do
    before do
      rsvp = create(:volunteer_rsvp, event: @event)
      sign_in_as(rsvp.user)
    end

    it 'is not allowed' do
      visit event_event_sessions_path(@event)
      current_path.should == events_path
    end
  end

  describe "as a checkiner" do
    before do
      rsvp = create(:volunteer_rsvp, event: @event, checkiner: true)

      @student_rsvp = create(:student_rsvp, event: @event)
      @student = @student_rsvp.user
      @student_rsvp_session = create(:rsvp_session, rsvp: @student_rsvp, event_session: @event.event_sessions.first)
      sign_in_as(rsvp.user)
    end

    it "lets the user check in attendees", js: true do
      visit event_event_sessions_path(@event)

      click_link "Check in for Unique Session Name"

      page.should have_content("Check-ins for Unique Session Name")

      within "#rsvp_session_#{@student_rsvp_session.id}" do
        within "#create_rsvp_session_#{@student_rsvp_session.id}" do
          click_on 'Check In'
        end
        page.should have_content('Checked In!')
      end

      within '.checkin-counts' do
        page.should have_content("1")
      end
    end
  end
end
