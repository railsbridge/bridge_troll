require 'spec_helper'

describe "the individual event page" do
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

    it "does not display the Edit link" do
      visit event_path(@event)
      page.should_not have_content("Edit")
    end

    it "does not display the event public email" do
      visit event_path(@event)
      page.should_not have_content("public_email@example.org")
    end

    it "displays a course if course is chosen" do
      visit event_path(@event)
      page.should have_content("The focus will be on ")
    end

    it "does not display a course if course is nil" do
      #destroy course to simulate old events
      @event.update_attributes(:course_id => nil)
      @event.save!
      visit event_path(@event)
      page.should_not have_content("The focus will be on ")

      #put course back for following tests
      @event.update_attributes(:course_id => Course::RAILS.id)
      @event.save!
    end

  end

  context "user is logged in but is not an organizer for the event" do
    before do
      @user = create(:user)
      sign_in_as(@user)
    end

    it "does not display the Edit link" do
      visit event_path(@event)
      page.should_not have_content("Edit")
    end

    it "displays the event public email" do
      visit event_path(@event)
      page.should have_content("public_email@example.org")
    end

    context "when user has not rsvp'd to event" do
      it "should allow user to volunteer" do
        visit event_path(@event)
        page.should have_link("Volunteer")
      end

      it "should allow user to attend as a student" do
        visit event_path(@event)

        page.should have_link("Attend as a student")
        page.should_not have_link("Join the waitlist")
      end

      context "when the event is full" do
        before(:each) do
          Event.any_instance.stub(:at_limit?).and_return(true)
        end

        it "should allow the user to join the waitlist" do
          visit event_path(@event)
          page.should_not have_link("Attend as a student")
          page.should have_link("Join the waitlist")
        end
      end
    end

    context "when user has rsvp'd to event" do
      before(:each) do
        create(:rsvp, event: @event, user: @user)
      end

      it "should allow user to cancel their RSVP" do
        visit event_path(@event)
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
      page.should_not have_selector('.rsvp-actions')
    end
  end
end
