require 'rails_helper'

describe "the event detail page" do
  let(:rsvp_actions_selector) { '.rsvp-actions' }
  before do
    @event = create(:event, public_email: "public_email@example.org")
  end

  context "user is not logged in" do
    it "shows a list of volunteers for the event" do
      user1 = create(:user)
      user2 = create(:user)
      create(:rsvp, user: user1, event: @event)
      visit event_path(@event)

      expect(page).to have_content(user1.full_name)
      expect(page).not_to have_content(user2.full_name)
    end

    it "shows who is organizing the event" do
      visit event_path(@event)
      within(".organizers") do
        expect(page).to have_content("No Organizer Assigned")
      end

      user1 = create(:user)
      user2 = create(:user)
      @event.organizers << user1
      @event.organizers << user2

      visit event_path(@event)
      within(".organizers") do
        expect(page).to have_content(user1.full_name)
        expect(page).to have_content(user2.full_name)
      end
    end

    it "does not display the Edit link, public email, volunteer or student details" do
      visit event_path(@event)
      expect(page).not_to have_content("Edit")
      expect(page).not_to have_content(@event.public_email)
      expect(page).not_to have_content(@event.volunteer_details)
      expect(page).not_to have_content(@event.student_details)
    end

    it "shows both locations for multiple-location events" do
      session_location = create(:location)
      create(:event_session, event: @event, location: session_location)

      visit event_path(@event)
      expect(page).to have_content(@event.location.name)
      expect(page).to have_content(session_location.name)
    end

    describe "course section" do
      let(:chosen_course_text) { "The focus will be on " }

      context "when a course is chosen" do
        it "displays a course and has a link to get the course level descriptions" do
          visit event_path(@event)
          expect(page).to have_content(chosen_course_text)

          click_link "Click here for more information about class levels in this course!"
          expect(page).to have_content("Class Levels for")
        end
      end

      context "when a course is not chosen" do
        before do
          @event.update_attributes(course_id: nil)
        end

        it "does not display a course" do
          visit event_path(@event)
          expect(page).not_to have_content(chosen_course_text)
        end
      end
    end

    describe 'RSVPing', js: true do
      it 'shows links to RSVP and allows the user to sign in through a modal after clicking them' do
        @user = create(:user)

        visit event_path(@event)

        expect(page).to have_selector(rsvp_actions_selector)
        click_link 'Volunteer'

        sign_in_with_modal(@user)

        expect(page).to have_content('RSVP')
        expect(current_path).to eq(volunteer_new_event_rsvp_path(@event))
      end

      it 'redirects the user back to the event show page if they sign up using the modal' do
        visit event_path(@event)
        click_link 'Attend as a student'

        expect(page).to have_selector('#sign_in_dialog', visible: true)
        within "#sign_in_dialog" do
          page.find(".sign_up_link").click
        end

        within("#sign-up") do
          fill_in "user_first_name", with: 'Sven'
          fill_in "user_last_name", with: 'Userson'
          fill_in "Email", with: 'sven@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'Sign up'
        end

        expect(page).to have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
        expect(current_path).to eq(event_path(@event))
      end
    end
  end

  context "user is logged in but is not an organizer for the event" do
    let(:attend_as_student_text) { "Attend as a student" }
    let(:join_student_waitlist_text) { "Join the student waitlist" }
    let(:attend_as_volunteer_text) { "Volunteer" }
    let(:join_volunteer_waitlist_text){ "Join the volunteer waitlist" }
    before do
      @user = create(:user)
      sign_in_as(@user)
    end

    it "displays the event public email but not the Edit link" do
      visit event_path(@event)
      expect(page).to have_content("public_email@example.org")
      expect(page).not_to have_content("Edit")
    end

    context "when user has not rsvp'd to event" do
      it "should allow user to rsvp as a volunteer or student" do
        visit event_path(@event)
        expect(page).to have_link("Volunteer")
        expect(page).to have_link(attend_as_student_text)
        expect(page).not_to have_link(join_student_waitlist_text)
      end

      context "when the event is full" do
        before(:each) do
          allow_any_instance_of(Event).to receive(:students_at_limit?).and_return(true)
          allow_any_instance_of(Event).to receive(:volunteers_at_limit?).and_return(true)
        end

        it "should allow the user to join the student waitlist" do
          visit event_path(@event)
          expect(page).not_to have_link(attend_as_student_text)
          expect(page).to have_link(join_student_waitlist_text)
        end

        it "should allow the user to join the volunteer waitlist" do
          visit event_path(@event)
          expect(page).not_to have_link(attend_as_volunteer_text)
          expect(page).to have_link(join_volunteer_waitlist_text)
        end
      end
    end

    context "when a volunteer has rsvp'd to event" do
      before(:each) do
        create(:rsvp, event: @event, user: @user)
        visit event_path(@event)
      end

      it "allows user to see volunteer details and lets them cancel their RSVP" do
        expect(page).to have_content(@event.volunteer_details)

        expect(page).to have_link("Cancel RSVP")
      end
    end

    context "when a student has rsvp'd to an event" do
      before(:each) do
        create(:student_rsvp, event: @event, user: @user)
        visit event_path(@event)
      end

      it "allows user to see student details and lets them cancel their RSVP" do
        expect(page).to have_content(@event.student_details)

        expect(page).to have_link("Cancel RSVP")
      end
    end
  end

  context "user is logged in and is an organizer of the event" do
    before do
      user = create(:user)
      @event.organizers << user
      sign_in_as(user)
    end

    it "lets the user edit the event" do
      visit event_path(@event)
      click_link "Edit"
      fill_in "Title", with: "New totally awesome event"
      click_button "Update Event"

      visit event_path(@event)
      expect(page).to have_content "New totally awesome event"
    end

    context 'when an event has some sessions with no RSVPs' do
      before do
        create(:event_session, event: @event)
      end

      it "can remove those sessions", js: true do
        expect(@event.event_sessions.count).to eq(2)

        visit edit_event_path(@event)

        page.find('.form-section-header', text: 'Event Description').click
        expect(page).to have_css('.remove-session')
        page.all('.remove-session')[-1].click

        page.find('.form-section-header', text: 'Event Description').click
        expect(page).to have_css('.event-sessions .fields', count: 1)

        expect(@event.event_sessions.count).to eq(1)
      end
    end
  end

  context "historical (meetup) events" do
    before do
      external_event_data = {
        type: 'meetup',
        student_event: {
          id: 901,
          url: 'http://example.com/901'
        }, volunteer_event: {
          id: 902,
          url: 'http://example.com/901'
        }
      }
      @event.update_attributes(student_rsvp_limit: nil, external_event_data: external_event_data)
    end

    it 'does not render rsvp actions' do
      visit event_path(@event)
      expect(page).not_to have_selector(rsvp_actions_selector)
    end
  end

  context "past events" do
    before do
      @event.update_attributes(ends_at: 1.day.ago)
    end

    it 'does not render rsvp actions' do
      visit event_path(@event)
      expect(page).not_to have_selector(rsvp_actions_selector)
    end
  end
end
