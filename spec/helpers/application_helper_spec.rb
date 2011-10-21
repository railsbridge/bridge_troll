require 'spec_helper'

describe ApplicationHelper do
  it "makes a link for an object" do
    event = Event.new
    event.stub! :id => 3, :to_s => "hi", :new_record? => false
    helper.link_for(event).should == '<a href="/events/3">hi</a>'  
  end
end
