require 'spec_helper'

describe "Making a new registration" do
  include CoreHelper

  before :each do
    @event = create_event
  end

  it "should be able to land on the registration page" do
    visit event_path @event
    click_link "Register for this event"
   end
end
