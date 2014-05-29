require 'spec_helper'

describe "the individual event page" do
  let(:rsvp_actions_selector) { '.rsvp-actions' }
  before do
    @event = create(:event, :public_email => "public_email@example.org")
  end

  context "user is not logged in" do
    it "shows a list of volunteers for the event" do
      user1 = create(:user)
      user2 = create(:user)
      create(:rsvp, :user => user1, :event => @event)
      visit event_path(@event)

      page.should have_content(user1.full_name)
      page.should_not have_content(user2.full_name)
    end

    it "shows who is organizing the event" do
      visit event_path(@event)
      within(".organizers") do
        page.should have_content("No Organizer Assigned")
      end

      user1 = create(:user)
      user2 = create(:user)
      @event.organizers << user1
      @event.organizers << user2

      visit event_path(@event)
      within(".organizers") do
        page.should have_content(user1.full_name)
        page.should have_content(user2.full_name)
      end
    end

    it "does not display the Edit link, public email, volunteer or student details" do
      visit event_path(@event)
      page.should_not have_content("Edit")
      page.should_not have_content(@event.public_email)
      page.should_not have_content(@event.volunteer_details)
      page.should_not have_content(@event.student_details)
    end

    describe "course section" do
      let(:chosen_course_text) { "The focus will be on " }

      context "when a course is chosen" do
        it "displays a course and has a link to get the course level descriptions" do
          visit event_path(@event)
          page.should have_content(chosen_course_text)

          click_link "Click here for more information about class levels in this course!"
          page.should have_content("Class Levels for")
        end
      end

      context "when a course is not chosen" do
        before do
          @event.update_attributes(:course_id => nil)
        end

        it "does not display a course" do
          visit event_path(@event)
          page.should_not have_content(chosen_course_text)
        end
      end
    end

    describe 'RSVPing', js: true do
      it 'shows links to RSVP and allows the user to sign in through a modal after clicking them' do
        @user = create(:user)

        visit event_path(@event)

        page.should have_selector(rsvp_actions_selector)
        click_link 'Volunteer'

        sign_in_with_modal(@user)

        page.should have_content('RSVP')
        current_path.should == volunteer_new_event_rsvp_path(@event)
      end

      it 'redirects the user back to the event show page if they sign up using the modal' do
        visit event_path(@event)
        click_link 'Attend as a student'

        page.should have_selector('#sign_in_dialog', visible: true)
        within "#sign_in_dialog" do
          page.find(".sign_up_link").click
        end

        within("#sign-up") do
          fill_in "user_first_name", :with => 'Sven'
          fill_in "user_last_name", :with => 'Userson'
          fill_in "Email", :with => 'sven@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'Sign up'
        end

        page.should have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')
        current_path.should == event_path(@event)
      end
    end
  end

  context "user is logged in but is not an organizer for the event" do
    let(:attend_as_student_text) { "Attend as a student" }
    let(:join_waitlist_text) { "Join the waitlist" }
    before do
      @user = create(:user)
      sign_in_as(@user)
    end

    it "displays the event public email but not the Edit link" do
      visit event_path(@event)
      page.should have_content("public_email@example.org")
      page.should_not have_content("Edit")
    end

    context "when user has not rsvp'd to event" do
      it "should allow user to rsvp as a volunteer or student" do
        visit event_path(@event)
        page.should have_link("Volunteer")
        page.should have_link(attend_as_student_text)
        page.should_not have_link(join_waitlist_text)
      end

      context "when the event is full" do
        before(:each) do
          Event.any_instance.stub(:at_limit?).and_return(true)
        end

        it "should allow the user to join the waitlist" do
          visit event_path(@event)
          page.should_not have_link(attend_as_student_text)
          page.should have_link(join_waitlist_text)
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

        page.should have_link("Cancel RSVP")
      end
    end

    context "when a student has rsvp'd to an event" do
      before(:each) do
        create(:student_rsvp, event: @event, user: @user)
        visit event_path(@event)
      end

      it "allows user to see student details and lets them cancel their RSVP" do
        expect(page).to have_content(@event.student_details)

        page.should have_link("Cancel RSVP")
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
      page.should have_content "New totally awesome event"
    end

    it "doesn't let user remove sessions" do
      visit event_path(@event)
      page.should_not have_selector('.remove-session')
    end
  end

  context "historical (meetup) events" do
    before do
      @event.update_attributes(student_rsvp_limit: nil, meetup_student_event_id: 901, meetup_volunteer_event_id: 902)
    end

    it 'does not render rsvp actions' do
      visit event_path(@event)
      page.should_not have_selector(rsvp_actions_selector)
    end
  end

  context "past events" do
    before do
      @event.update_attributes(ends_at: 1.day.ago)
    end

    it 'does not render rsvp actions' do
      visit event_path(@event)
      page.should_not have_selector(rsvp_actions_selector)
    end
  end
end
