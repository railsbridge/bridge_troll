require 'spec_helper'

describe Event do
  it "should be able to return a date time object from a human readable format input" do
    params = {}
    params[:start_time] = "June 8, 2011"
    params[:end_time] = "June 9, 2011"
    new_params = Event.from_form(params)
    new_params[:start_time].class.should == DateTime && new_params[:end_time].class.should == DateTime
  end

  describe "with two users signed up and only capacity for one" do
    before do
      @event = Event.new :capacity => 1
      @first = mock User
      @second = mock User
      @event.stub! :users => [@first, @second]
    end
  end
end
