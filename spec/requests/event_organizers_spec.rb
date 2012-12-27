require 'spec_helper'

describe "Event Organizers" do
  before do
    @user_organizer = create(:user, email: "orgainzer@mail.com", name: "Sam Spade")
    @user1 = create(:user, email: "user1@mail.com", name: "Joe Cairo")

    @user1.update_attributes(:hacking => true, :teaching => true)

    @event =  Event.create!(:title => 'New workshop', :date => DateTime.now + 1.fortnight)

    @rsvp1 = VolunteerRsvp.create!(:user_id => @user1.id, :event_id => @event.id, :attending => true)

    @event.organizers << @user_organizer

    visit new_user_session_path

    fill_in "Email",    :with => @user_organizer.email
    fill_in "Password", :with => @user_organizer.password
    click_button "Sign in"

    visit '/events/' + @event.id.to_s
    click_link "Manage Organizers"
  end

  it "should display the Manage Organizers Page" do
    page.should have_content("Organizer Assignments")
  end

  it "should display the assigned organizers email" do
    page.should have_content("orgainzer@mail.com")
    page.should have_content("Sam Spade")
  end

  #it "should have unassigned users as options the user select" do
  #  page.should have_xpath "//select[@id = 'event_organizer_user_id']/option[@value = '2']"
  #  find("option[value=#{@user1.id.to_s}]").text.should == "Joe Cairo"
  #end

  #it "should assign the selected user as an organizer and display the name and email" do
  #  find("option[value='2']").click
  #  click_button "Assign"
  #
  #  visit '/events/' + @event.id.to_s
  #
  #  page.should have_content("user1@mail.com")
  #  page.should have_content("Joe Cairo")
  #end

  #it "should assign the selected user as an organizer and remove the selected user from the user select options" do
  #  find("option[value='2']").click
  #  click_button "Assign"
  #
  #  visit '/events/' + @event.id.to_s
  #
  #  page.should_not have_selector('option')
  #end

end