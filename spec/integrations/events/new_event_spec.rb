require 'spec_helper'

describe "Creating a new event" do
  include CoreHelper

  it "should be able to create a new event" do
    old_events = Event.all
    create_event
    old_events.length.should < Event.all.length
  end

  it "should be able to select a different location" do
    new_location = Location.last.name
    create_event({:location => new_location})
    Event.last.location.name.should == new_location
  end
end
