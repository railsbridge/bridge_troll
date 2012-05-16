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
      
      describe "volunteer" do

        it "should have a volunteer method" do
          @event.should respond_to(:volunteer!)
        end
    
        it "should not create duplicate volunteer_rsvps" do
          @event.volunteer!(@user)
      
          #this method is useful for detecting if there is actually a new duplicate record generated in the database
          expect {        
          @event.volunteer!(@user)
          }.should_not change(VolunteerRsvp, :count).by(1)
     
          #this method is useful for detecting when VolunteerRSVP model validation breaks
          duplicate_volunteer_rsvp = VolunteerRsvp.new(:user_id => @user.id, :event_id => @event.id, :attending => true)
          duplicate_volunteer_rsvp.should_not be_valid
      
        end
    
        it "should create a volunteer_rsvp" do
          expect {        
          @event.volunteer!(@user)
          }.should change(VolunteerRsvp, :count).by(1)
        end
    
        it "should create a volunteer_rsvp that persists and is valid" do
          @rsvp = @event.volunteer!(@user)
          @rsvp.should be_persisted
          @rsvp.should be_valid
        end
     
        it "should give the new volunteer_rsvp with correct attributes" do
          @rsvp = @event.volunteer!(@user)
          @rsvp.user_id.should == @user.id
          @rsvp.event_id.should == @event.id
          @rsvp.attending.should == true
        end    
      end
  
      describe "unvolunteer" do

        it "should have an unvolunteer method" do
          @event.should respond_to(:unvolunteer!)
        end
    
        it "should change the attending attribute to false" do
          @rsvp = @event.volunteer!(@user)
          @rsvp.attending.should == true
      
          @event.unvolunteer!(@user)
          changedStatus = @event.volunteer_rsvps.find_by_user_id(@user.id).attending
          changedStatus.should == false 
        end
      end
  
      describe "volunteering?" do
            
        it "should have a volunteering? method" do
           @event.should respond_to(:volunteering?)
        end
    
        it "should be true when a user is volunteering at an event" do
          @event.volunteer!(@user)
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

  describe "upcoming?" do
    before do
      @event_past = create(:event, :date => Date.yesterday)
      @event_future = create(:event, :date => Date.tomorrow)
      @event_beginning_of_today = create(:event, :date => Time.now.utc.beginning_of_day)
      @event_end_of_yesterday = create(:event, :date => Time.now.utc.beginning_of_day - 1)
    end
    it "should not include events earlier than today" do
      Event.upcoming.should_not include(@event_past)
    end
     it "should include events later than today" do
      Event.upcoming.should include(@event_future)
    end
     it "should include events from earlier today" do           # edge case to pass
      Event.upcoming.should include(@event_beginning_of_today)
    end
    it "should not include events from end of yesterday" do     # edge case to fail
      Event.upcoming.should_not include(@event_end_of_yesterday)
    end
 end
end
