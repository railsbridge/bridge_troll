require 'spec_helper'

describe "Creating a new event" do
  include CoreHelper

  it "should be able to create a new event" do
    old_events = Event.all
    visit new_event_path
    create_event
    old_events.length.should < Event.all.length
  end

  it "should be able to select a different location" do
    new_location = Location.last.name
    visit new_event_path
    create_event({:location => new_location})
    Event.last.location.name.should == new_location
  end

  it "should be able to create an event through basic interactions" do
    old_events = Event.all
    visit "/"
    click_link "Create a workshop"
    create_event
    old_events.length.should < Event.all.length
  end
end
