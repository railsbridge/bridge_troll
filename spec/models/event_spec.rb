require 'spec_helper'

describe Event do  
  before do
    @event = create(:event)
    @user = create(:user)
  end

  it { should belong_to(:location) }
  it { should have_many(:rsvps) }
  it { should have_many(:event_sessions) }
  it { should validate_numericality_of(:student_rsvp_limit) }

  it { should validate_presence_of(:title) }
  it "validates that there is at least one event session" do
    event = create(:event)
    event.event_sessions.destroy_all
    event.should_not be_valid

    event.event_sessions << build(:event_session)
    event.should be_valid  
  end

  it "must have a time zone" do
    event = build(:event, :time_zone => nil)
    event.should have(1).error_on(:time_zone)
  end

  it "must have a valid time zone" do
    event = build(:event, :time_zone => "xxx")
    event.should have(1).error_on(:time_zone)

    event = build(:event, :time_zone => 'Hawaii')
    event.should have(0).errors
  end

  describe '#rsvps_with_childcare' do
    it 'includes all rsvps with childcare requested' do
      @event.rsvps_with_childcare.should == @event.student_rsvps.needs_childcare + @event.volunteer_rsvps.needs_childcare
    end
  end

  describe "#volunteer?" do
    it "is true when a user is volunteering at an event" do
      create(:rsvp, :user => @user, :event => @event)
      @event.volunteer?(@user).should == true
    end

    it "is false when a user is not volunteering at an event" do
      @event.volunteer?(@user).should == false
    end
  end

  describe "#rsvp_for_user" do
    it "should return the rsvp for a user" do
      @event.rsvp_for_user(@user).should == @event.rsvps.find_by_user_id(@user.id)
    end
  end

  describe ".upcoming" do
    before do
      @event_past = build(:event_with_no_sessions)
      @event_past.event_sessions << create(:event_session, starts_at: 4.weeks.ago, ends_at: 3.weeks.ago)
      @event_past.save!

      @event_future = build(:event_with_no_sessions)
      @event_future.event_sessions << create(:event_session, starts_at: 3.weeks.from_now, ends_at: 4.weeks.from_now)
      @event_future.save!

      @event_in_progress = build(:event_with_no_sessions)
      @event_in_progress.event_sessions << create(:event_session, starts_at: 2.days.ago, ends_at: 2.days.from_now)
      @event_in_progress.save!
    end
  
    it "includes events that haven't yet started" do
      Event.upcoming.should include(@event_future)
    end
  
    it "includes events in progress" do
      Event.upcoming.should include(@event_in_progress)
    end

    it "doesn't include events that have already ended" do
      Event.upcoming.should_not include(@event_past)
    end
  end
  
  describe "#details" do
    it "has default content" do
      Event.new.details.should =~ /Workshop Description/
    end
  end
end
