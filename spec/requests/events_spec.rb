require 'spec_helper'

describe "Events" do
  
  it "listing should show blank Location if no location_id exists" do
    location = create(:location, :name => 'locname')
    event = create(:event, :location_id => nil, :title => 'mytitle')
    visit events_path
    page.should have_content('Upcoming events')
  end

  it "should create a new event" do
    @user = create(:user)
    visit new_user_session_path
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"
        
    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
    visit events_path
    click_link "New Event"

    fill_in "Title", :with=>"February Event"
    select "February",:from =>"event[date(2i)]"
    select (Time.now.year + 1).to_s,:from =>"event[date(1i)]"   # so it will be "upcoming"
    click_button "Create Event"

    page.should have_content("February Event")
    page.should have_content("This event currently has no location!")

    visit events_path

    page.should have_content("February Event")
  end
 
  it "should not create an event if user is not logged in" do
    visit new_event_path
    page.should have_content("You need to sign in or sign up before continuing")
  end
  
  it "should allow user to volunteer for event" do
    @user = create(:user)
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"
    visit events_path
    click_link "New Event"
    fill_in "Title", :with => "March Event"
    select "March",:from =>"event[date(2i)]"
    select (Time.now.year + 1).to_s,:from =>"event[date(1i)]"   # so it will be "upcoming"
    click_button "Create Event"
    visit events_path

    page.should have_content("March Event")
    page.should have_link("Volunteer")
    @event = Event.where(:title=> 'March Event').first
    click_link("Volunteer")
    page.should have_content("Thanks for volunteering")
    @rsvp = VolunteerRsvp.where(:event_id=> @event_id, :user_id => @user.id).first
     
  end
  
  it "should show list of volunteers for event" do
    @user1 = create(:user)
    visit new_user_session_path
    @user1.hacking = true
    @user1.taing = true
    @user2 = create(:user)

    @event = Event.new
    @event.title = 'New workshop'
    @event.date = DateTime.now
    @event.save!

    @rsvp = VolunteerRsvp.new
    @rsvp.user_id = @user1.id
    @rsvp.event_id = @event.id
    @rsvp.attending = true
    @rsvp.save!

    visit '/events/' + @event.id.to_s

    page.should have_content("Volunteers")
    page.should have_content(@user1.email)
    page.should_not have_content(@user2.email)
  end

  it "should not display the edit link if the user is not an organizer for the event" do
    @event = create(:event, title: "Click Me")
    @user = create(:user)
    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    click_link "Click Me"
    page.should_not have_content("Edit")

  end

  it "should display the edit link and render the edit form if the user is an organizer for the event" do
    @event = create(:event, title: "Pick Me")
    @user = create(:user)
    @event.organizers << @user

    visit new_user_session_path

    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    click_link "Pick Me"
    page.should have_content("Edit")

    click_link "Edit"
    page.should_not have_content("Update Event")

  end

  it "should display the edit link and render the edit form if the user is an admin" do
    @admin = create(:user, admin: true)
    @event = create(:event, title: "Pick Me")

    visit new_user_session_path

    fill_in "Email", :with => @admin.email
    fill_in "Password", :with => @admin.password
    click_button "Sign in"

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
    @user = create(:user, name: "Sam Spade")
    @event.organizers << @user

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizer:")
    page.should have_content("Sam Spade")
  end

  it "should display 'Organizers:' and the organizers names if the event has more than one organizer" do
    @event = create(:event, title: "Pick Me")
    @user1 = create(:user, name: "Sam Spade")
    @user2 = create(:user, name: "Joel Cairo")
    @event.organizers << @user1
    @event.organizers << @user2

    visit '/events'
    click_link "Pick Me"
    page.should have_content("Organizers:")
    page.should have_content("Sam Spade")
    page.should have_content("Joel Cairo")
  end




end
