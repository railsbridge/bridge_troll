require 'spec_helper'

describe "Creating a new event" do
  it "should be able to create a new event" do
    old_events = Event.all
    visit new_event_path
    fill_in "event[name]", :with => "test"
    click_button "Create event"
    old_events.length.should < Event.all.length
  end
end
