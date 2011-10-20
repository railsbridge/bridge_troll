require 'spec_helper'

describe "Creating a new event" do
  it "should be able to create a new event" do
    old_events = Event.all
    visit new_event_path
    fill_in "event[name]", :with => "test"
    click_button "Create event"
    old_events.length.should < Event.all.length
  end

  it "should be able to select a different location" do
    visit new_event_path
    new_location = Location.last.name
    fill_in "event[name]", :with => "test"
    select(new_location, :from => "event[location_id]")
    click_button "Create event"
    Event.last.location.name.should == new_location
  end
end
