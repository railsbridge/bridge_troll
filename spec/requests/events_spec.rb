require 'spec_helper'

describe "Events" do
  it "listing should show blank Location if no location_id exists" do
    create(:location, :name => 'locname')
    create(:event, :location_id => nil, :title => 'mytitle')
    visit events_path
    page.should have_content('Upcoming events')
  end

  it "creates a new event" do
    @user = create(:user)
    details_note = "This is a note in the detail text box\n With a new line!"

    title = "February Event"
    sign_in_as(@user)

    visit events_path
    click_link "New Event"

    fill_in "Title", :with=> title
    select "February",:from =>"event[date(2i)]"
    select (Time.now.year + 1).to_s,:from =>"event[date(1i)]"   # so it will be "upcoming"
    fill_in "Details", :with => details_note
    click_button "Create Event"

    page.should have_content(title)
    page.should have_content("This event currently has no location!")
    page.should have_content("This is a note in the detail text box")
    page.should have_css(".details p", text: 'With a new line!')

    visit events_path

    page.should have_content("February Event")
  end
 
  it "should not create an event if user is not logged in" do
    visit new_event_path
    page.should have_content("You need to sign in or sign up before continuing")
  end
  
  it "should allow user to volunteer for event" do
    @user = create(:user)
    @event = create(:event)

    sign_in_as(@user)

    page.should have_link("Volunteer")
    click_link("Volunteer")
    page.should have_content("Thanks for volunteering")
    @rsvp = VolunteerRsvp.where(:event_id=> @event.id, :user_id => @user.id).first
  end
  
  it "should show list of volunteers for event" do
    @user1 = create(:user, first_name: "Shirlee", last_name: "Smith")
    @user1.profile.update_attributes(:hacking => true, :taing => true)
    @user2 = create(:user)

    @event = create(:event)

    @rsvp = VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)

    visit '/events/' + @event.id.to_s

    page.should have_content("Volunteers")
    page.should have_content("#{@user1.full_name}")
    page.should_not have_content(@user2.full_name)
  end

  it "should not display the Manage Organizers link if the user is not an organizer for the event" do
    @event = create(:event, title: "Pick Me")

    visit '/events'
    click_link "Pick Me"
    page.should_not have_content("Manage Organizers")
  end

  it "should display the Manage Organizers link if the user is an organizer for the event" do
    @event = create(:event, title: "Click Me")
    @user = create(:user)
    @event.organizers << @user

    sign_in_as(@user)

    click_link "Click Me"

    page.should have_content("Manage Organizers")
  end

  it "should display the Manage Organizers link if the user is an admin" do
    @event = create(:event, title: "Click Me")
    @user = create(:user, admin: true)

    sign_in_as(@user)

    click_link "Click Me"

    page.should have_content("Manage Organizers")
  end

  describe "Organizer Assignment" do
    before do
      @event = create(:event, title: "Click Me")
      @user = create(:user)
      @event.organizers << @user

      sign_in_as(@user)

      click_link "Click Me"
    end

    it "should display the Organizer Assignment page" do
      click_link "Manage Organizers"

      page.should have_content("Organizer Assignment")
    end
  end

  it "should not display the edit link if the user is not an organizer for the event" do
    @event = create(:event, title: "Click Me")
    @user = create(:user)

    sign_in_as(@user)

    click_link "Click Me"
    page.should_not have_content("Edit")
  end

  it "should display the edit link and render the edit form if the user is an organizer for the event" do
    @event = create(:event, title: "Pick Me")
    @user = create(:user)
    @event.organizers << @user

    sign_in_as(@user)

    click_link "Pick Me"
    page.should have_content("Edit")

    click_link "Edit"
    page.should_not have_content("Update Event")
  end

  it "should display the edit link and render the edit form if the user is an admin" do
    @admin = create(:user, admin: true)
    @event = create(:event, title: "Pick Me")

    sign_in_as(@admin)

    click_link "Pick Me"
    page.should have_content("Edit")

    click_link "Edit"
    page.should_not have_content("Update Event")
  end

  it "should display 'No Organizer Assigned' if no organizer is linked to the event" do
    @event = create(:event, title: "Pick Me")

    visit '/events'
    click_link "Pick Me"
    page.should have_content("No Organizer Assigned")
  end

  it "should display 'Organizer:' and the organizers name if the event has only one organizer" do
    @event = create(:event, title: "Pick Me")
    @user = create(:user, first_name: "Sam", last_name: "Spade")
    @event.organizers << @user

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizer:")
    page.should have_content("Sam Spade")
  end

  it "should display 'Organizers:' and the organizers names if the event has more than one organizer" do
    @event = create(:event, title: "Pick Me")
    @user1 = create(:user, first_name: "Sam", last_name: "Spade")
    @user2 = create(:user, first_name: "Joel", last_name: "Cairo")
    @event.organizers << @user1
    @event.organizers << @user2

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizers:")
    page.should have_content("Sam Spade")
    page.should have_content("Joel Cairo")
  end

  describe "organizer vs. non-organizer differences" do
    before do
      @user1 = create(:user, email: "user1@mail.com", first_name: "Sam", last_name: "Spade")
      @user2 = create(:user, email: "user2@mail.com", first_name: "Joel", last_name: "Cairo")

      @user1.update_attributes(:hacking => true, :teaching => true)
      @user2.update_attributes(:hacking => true, :taing    => true)

      @event =  create(:event)

      @rsvp1 = VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)
      @rsvp2 = VolunteerRsvp.create!(:user_id => @user2.id, :event_id => @event.id, :attending => true)
    end

    it "should only display the name of a volunteer for non organizers" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content(@user1.email)
      page.should have_content("#{@user1.full_name}")
    end

    it "should display the email addresses of volunteers for an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      sign_in_as(@user_organizer)

      visit '/events/' + @event.id.to_s

      page.should have_content(@user1.email)
      page.should have_content("#{@user1.full_name}")
    end

    it "should not display the teaching preference to a non-organizer" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content("Willing to Teach:")
      page.should_not have_content("Willing to TA:")
      page.should_not have_content("#{@user1.full_name} - #{@user1.email}")
      page.should_not have_content("#{@user2.full_name} - #{@user2.email}")
    end

    it "should display the teaching preference to an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      sign_in_as(@user_organizer)

      visit '/events/' + @event.id.to_s
      page.should have_content("Willing to Teach:")
      page.should have_content("Willing to TA:")
      page.should have_content("#{@user1.full_name} - #{@user1.email}")
      page.should have_content("#{@user2.full_name} - #{@user2.email}")
    end
  end

  describe "four categories for volunteer's teaching preference" do
    def add_volunteer_to_event(event, attributes)
      user = create(:user)
      user.profile.update_attributes(attributes)
      VolunteerRsvp.create!(user_id: user.id, event_id: event.id, attending: true)
    end

    before do
      @event = create(:event)

      4.times { add_volunteer_to_event(@event, hacking: true, teaching: true) }
      3.times { add_volunteer_to_event(@event, hacking: true, taing: true) }
      2.times { add_volunteer_to_event(@event, hacking: true, teaching: true, taing: true) }
      1.times { add_volunteer_to_event(@event, hacking: true) }
    end

    it "should display the four teacher preference sections for an organizer" do
      @user_organizer = create(:user)
      @event.organizers << @user_organizer

      sign_in_as(@user_organizer)

      visit '/events/' + @event.id.to_s

      page.should have_content("Willing to Teach: 4")
      page.should have_content("Willing to TA: 3")
      page.should have_content("Willing to Teach or TA: 2")
      page.should have_content("Not Interested in Teaching: 1")
      page.should have_content("All Volunteers: 10")

      page.should have_selector('.teach', :count => 4)
      page.should have_selector('.ta',    :count => 3)
      page.should have_selector('.both',  :count => 2)
      page.should have_selector('.none',  :count => 1)
    end

    it "should not display the four teacher preference sections for a non-organizer" do
      visit '/events/' + @event.id.to_s

      page.should_not have_content("Willing to Teach")
      page.should_not have_content("Willing to TA")
      page.should_not have_content("Willing to Teach or TA")
      page.should_not have_content("Not Interested in Teaching")
    end
  end
end
