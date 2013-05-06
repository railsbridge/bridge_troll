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

  describe "updating an event" do
    it "does not allow student_rsvp_limit to be decreased" do
      event = create(:event, student_rsvp_limit: 10)
      event.update_attributes(student_rsvp_limit: 5)
      event.should have(1).errors_on(:student_rsvp_limit)
    end

    it "does allow student_rsvp_limit to be increased" do
      event = create(:event, student_rsvp_limit: 10)
      event.update_attributes(student_rsvp_limit: 20)
      event.should have(0).errors_on(:student_rsvp_limit)
    end

    it "reorders the waitlist" do
      @event.should_receive(:reorder_waitlist!)
      @event.update_attributes(student_rsvp_limit: 200)
    end
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

  describe "#reorder_waitlist!" do
    before do
      @event.update_attribute(:student_rsvp_limit, 2)
      @confirmed1 = create(:student_rsvp, event: @event)
      @confirmed2 = create(:student_rsvp, event: @event)
      @waitlist1 = create(:student_rsvp, event: @event, waitlist_position: 1)
      @waitlist2 = create(:student_rsvp, event: @event, waitlist_position: 2)
      @waitlist3 = create(:student_rsvp, event: @event, waitlist_position: 3)
    end

    context "when the limit has increased" do
      before do
        @event.update_attribute(:student_rsvp_limit, 4)
      end

      it "promotes people on the waitlist into available slots when the limit increases" do
        @event.reorder_waitlist!
        @event.reload

        @event.student_rsvps.count.should == 4
        @event.student_waitlist_rsvps.count.should == 1
      end
    end

    context "when a confirmed rsvp has been destroyed" do
      before do
        @confirmed1.destroy
        @event.reorder_waitlist!
      end

      it 'promotes a waitlisted user to confirmed when the rsvp is destroyed' do
        @waitlist1.reload.waitlist_position.should be_nil
        @waitlist2.reload.waitlist_position.should == 1
        @waitlist3.reload.waitlist_position.should == 2
      end
    end

    context "when a waitlisted rsvp has been destroyed" do
      before do
        @waitlist1.destroy
        @event.reorder_waitlist!
      end

      it 'reorders the waitlist when the rsvp is destroyed' do
        @waitlist2.reload.waitlist_position.should == 1
        @waitlist3.reload.waitlist_position.should == 2
      end
    end
  end

  describe "waitlists" do
    before do
      @confirmed_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT, waitlist_position: 1)
    end

    it "returns only confirmed rsvps in #student_rsvps" do
      @event.student_rsvps.should == [@confirmed_rsvp]
    end

    it "returns only waitlisted rsvps in #student_waitlist_rsvps" do
      @event.student_waitlist_rsvps.should == [@waitlist_rsvp]
    end
  end
end
