require 'spec_helper'

describe "An event one hour from now" do
  it "should allow users to register as a volunteer" do
    event = create_event
    user = create_user(:name => "Chipotle")
    sign_in(user)
    click_link event.name
    click_button "Volunteer"
    within ".volunteers" do
      page.should have_content("Chipotle")
    end
  end
end