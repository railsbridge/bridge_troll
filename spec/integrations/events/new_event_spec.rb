require 'spec_helper'

describe "Creating a new event" do
  it "should be able to create a new event" do
    old_events = Event.all
    visit new_event_path
    create_event_with_app
    old_events.length.should < Event.all.length
  end

  it "should be able to select a different location" do
    new_location = Location.last.name
    visit new_event_path
    create_event_with_app({:location => new_location})
    Event.last.location.name.should == new_location
  end

  it "should be able to create an event through basic interactions" do
    old_events = Event.all
    visit "/"
    click_link "Create a workshop"
    create_event_with_app
    old_events.length.should < Event.all.length
  end

  it "should be able to create an event with a specific datetime to start" do
    visit new_event_path
    time = 5.days.from_now
    create_event_with_app({:start_time => time})
    Event.last.start_time.to_s.should == time.to_s
  end

  it "should be able to create an event with a human readable format for dates" do
    visit new_event_path
    create_event_with_app({:start_time => "June 8, 2011"})
    Event.last.start_time.should == DateTime.parse("June 8, 2011")
  end

  it "should be linked off the dashboard" do
    event = create_event
    sign_in
    click_link event.name
  end
end