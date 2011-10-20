require 'spec_helper'

describe "An event one hour from now" do
  it "should allow users to register as a volunteer" do
    event = create_event
    sign_in
    click_link event.name
    click_link "Volunteer"
  end
end