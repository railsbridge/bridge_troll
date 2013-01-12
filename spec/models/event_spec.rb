require 'spec_helper'

describe Event do  
  before do
    @event = create(:event)
    @user = create(:user)
  end

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:date) }
  
  it { should belong_to(:location) }
  it { should have_many(:volunteer_rsvps) }
  it { should have_many(:volunteers).through(:volunteer_rsvps) }
  it { should have_many(:event_organizers) }
  it { should have_many(:organizers).through(:event_organizers) }

  describe "#volunteering?" do
    it "is true when a user is volunteering at an event" do
      VolunteerRsvp.create(:event_id => @event.id, :user_id => @user.id, :attending => true)
      @event.volunteering?(@user).should == true
    end

    it "is false when a user is not volunteering at an event" do
      @event.volunteering?(@user).should == false
    end
  end

  describe "#rsvp_for_user" do
    it "should return the volunteer_rsvp for a user" do
      @event.rsvp_for_user(@user).should == @event.volunteer_rsvps.find_by_user_id(@user.id)
    end
  end

  describe ".upcoming" do
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
