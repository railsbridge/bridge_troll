require 'spec_helper'

describe "Making a new registration" do
  before :each do
    visit new_event_path
    @event = create_event_with_app
  end

  it "should be able to land on the registration page" do
    visit event_path @event
    click_link "Register for this event"
   end
end
