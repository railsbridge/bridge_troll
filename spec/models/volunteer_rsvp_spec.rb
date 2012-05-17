require 'spec_helper'

describe VolunteerRsvp do
  it "should not create duplicate volunteer_rsvps" do
    @event = create(:event)
    @user = create(:user)
    #this method is useful for detecting when VolunteerRSVP model validation breaks
    duplicate_volunteer_rsvp1 = VolunteerRsvp.create(:user_id => @user.id, :event_id => @event.id, :attending => true)
    duplicate_volunteer_rsvp1.should be_valid
    duplicate_volunteer_rsvp2 = VolunteerRsvp.new(:user_id => @user.id, :event_id => @event.id, :attending => true)
    duplicate_volunteer_rsvp2.should_not be_valid
  end
end
