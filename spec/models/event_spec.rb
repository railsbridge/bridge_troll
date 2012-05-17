require 'spec_helper'

describe Event do

  it "must have a title" do
    event = build(:event, :title => nil)
    event.should_not be_valid
  end
  
  it "must have a date" do
    event = build(:event, :date => nil)
    event.should_not be_valid
  end

  describe "for existing event" do
    before do
      @event = create(:event)
    end
  
    describe "volunteer rsvps role" do    
      it "should have a volunteer_rsvp method" do
        @event.should respond_to(:volunteer_rsvps)
      end   
    end
  
    describe "with existing user" do
      before do
        @user = create(:user)
      end 

      describe "volunteering?" do
        it "should have a volunteering? method" do
           @event.should respond_to(:volunteering?)
        end
    
        it "should be true when a user is volunteering at an event" do
          VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id, :attending => true)
          @event.volunteering?(@user).should == true
        end
    
        it "should be false when a user is not volunteering at an event" do
          @event.volunteering?(@user).should == false        
        end
      end

      describe "rsvp_for_user" do
        it "should return the volunteer_rsvp for a user" do
          @event.rsvp_for_user(@user).should == @event.volunteer_rsvps.find_by_user_id(@user.id)
        end
      end

    end
  end
end
