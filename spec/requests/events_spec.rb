require 'spec_helper'

describe "Events" do

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
    select "February",:from =>"event[date(2i)]"
    click_button "Create Event"
    visit events_path

    page.should have_content("March Event")
    page.should have_button("Volunteer")
    @event = Event.where(:title=> 'March Event').first
    visit volunteer_path(@event)
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

end
