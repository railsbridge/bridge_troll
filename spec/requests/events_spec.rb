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
    details_note = "This is a note in the detail text box"
    visit new_user_session_path
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"

    visit events_path
    click_link "New Event"

    fill_in "Title", :with=>"February Event"
    select "February",:from =>"event[date(2i)]"
    select (Time.now.year + 1).to_s,:from =>"event[date(1i)]"   # so it will be "upcoming"
    fill_in "event_details", :with => details_note
    click_button "Create Event"

    page.should have_content("February Event")
    page.should have_content("This event currently has no location!")
    page.should have_content(details_note)

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
    @user1 = create(:user, name: "Shirlee")
    visit new_user_session_path
    @user1.hacking = true
    @user1.taing = true
    @user2 = create(:user)

    @event = Event.create!(:title => "New workshop", :date => DateTime.now + 1.fortnight, :details => "Note of type detail")

    @rsvp = VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)

    visit '/events/' + @event.id.to_s

    page.should have_content("Volunteers")
    page.should have_content(@user1.name)
    page.should_not have_content(@user2.name)
  end
end
