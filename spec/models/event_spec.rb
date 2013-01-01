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
