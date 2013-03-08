require 'spec_helper'

describe "New Event" do
  before do
    @user_organizer = create(:user, email: "orgainzer@mail.com", first_name: "Sam", last_name: "Spade")
    
    sign_in_as(@user_organizer)

    visit "/events/new"
  end

  it "should pre-fill the event details textarea" do
    page.should have_field('General Event Details')
    page.field_labeled('General Event Details')[:value].should =~ /Workshop Description/
  end

  it "should have a public organizer email field" do
    page.should have_field("What email address should users contact you at with questions?")
  end
end
