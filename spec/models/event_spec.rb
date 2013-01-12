require 'spec_helper'

describe Event do  
  before do
    @event = create(:event)
    @user = create(:user)
  end

  it { should validate_presence_of(:title) }
  
  it { should belong_to(:location) }
  it { should have_many(:volunteer_rsvps) }
  it { should have_many(:volunteers).through(:volunteer_rsvps) }
  it { should have_many(:event_organizers) }
  it { should have_many(:organizers).through(:event_organizers) }
  it { should have_many(:event_sessions) }

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
      @event_past = create(:event)
      create(:event_session, event: @event_past, starts_at: 4.weeks.ago, ends_at: 3.weeks.ago)
      
      @event_future = create(:event)
      create(:event_session, event: @event_future, starts_at: 3.weeks.from_now, ends_at: 4.weeks.from_now)
      
      @event_in_progress = create(:event)
      create(:event_session, event: @event_in_progress, starts_at: 2.days.ago, ends_at: 2.days.from_now)
    end
  
    it "should not include events that have already ended" do
      Event.upcoming.should_not include(@event_past)
    end
  
    it "should include events that have not started" do
      Event.upcoming.should include(@event_future)
    end
  
    it "should include events in progress" do 
      Event.upcoming.should include(@event_in_progress)
    end
  end
end
