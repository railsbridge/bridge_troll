require 'spec_helper'

describe ApplicationHelper do
  it "makes a link for an object" do
    event = Event.new
    event.stub! :id => 3, :to_s => "hi", :new_record? => false
    helper.link_for(event).should == '<a href="/events/3">hi</a>'  
  end

  it "should describe the time" do
    start = Time.parse("October 20, 2011 11:56pm")
    helper.day_date_time(start).should == "Thursday October 20th 2011 at 11:56pm"
  end
end
