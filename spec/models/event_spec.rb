require 'spec_helper'

describe Event do
  it "must have a title" do
    event = Factory.build(:event, :title => nil)
    event.should_not be_valid
  end
  
  it "must have a date" do
    event = Factory.build(:event, :date => nil)
    event.should_not be_valid
  end
end