require 'spec_helper'

describe Event do
  before do
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

  it "sorts event_sessions by ends_at" do
    event = create(:event)

    session2 = event.event_sessions.first
    session2.update_attributes(starts_at: Time.now, ends_at: 1.hour.from_now)
    session3 = create(:event_session, event: event, starts_at: 20.days.from_now, ends_at: 21.days.from_now)
    session1 = create(:event_session, event: event, starts_at: 10.days.ago, ends_at: 9.days.ago)

    event.reload.event_sessions.should == [session1, session2, session3]
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
      event = create(:event, student_rsvp_limit: 10)
      event.should_receive(:reorder_waitlist!)
      event.update_attributes(student_rsvp_limit: 200)
    end
  end

  describe '#rsvps_with_childcare' do
    it 'includes all rsvps with childcare requested' do
      event = create(:event)
      event.rsvps_with_childcare.should == event.student_rsvps.needs_childcare + event.volunteer_rsvps.needs_childcare
    end
  end

  describe "#volunteer?" do
    let(:event) { create(:event) }
    
    it "is true when a user is volunteering at an event" do
      create(:rsvp, :user => @user, :event => event)
      event.volunteer?(@user).should == true
    end

    it "is false when a user is not volunteering at an event" do
      event.volunteer?(@user).should == false
    end
  end

  describe "#waitlisted_student?" do
    let(:event) { create(:event) }
    
    it "returns true when a user is a waitlisted student" do
      create(:student_rsvp, :user => @user, :event => event,  waitlist_position: 1)
      event.waitlisted_student?(@user).should == true
    end

    it "returns false when a user is not waitlisted" do
      create(:student_rsvp, :user => @user, :event => event)
      event.waitlisted_student?(@user).should == false
    end
  end

  describe "#rsvp_for_user" do
    it "should return the rsvp for a user" do
      event = create(:event)
      event.rsvp_for_user(@user).should == event.rsvps.find_by_user_id(@user.id)
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

    it "includes events that have not already ended" do
      Event.upcoming.all.map(&:id).should == [@event_in_progress.id, @event_future.id]
    end
  end

  describe "#details" do
    it "has default content" do
      Event.new.details.should =~ /Workshop Description/
    end
  end

  describe "#at_limit?" do
    context "when the event has a limit" do
      let(:event) { create(:event,  student_rsvp_limit: 2) }
      
      it 'is false when the limit is not exceeded has not exceeded it' do
        event.should_not be_at_limit
      end
      
      it 'is true when the limit is exceeded' do
        3.times { create(:student_rsvp, event: event) }
        event.should be_at_limit
      end
    end

    context "when the event has no limit (historical events)" do
      let(:event) { create(:event, student_rsvp_limit: nil, meetup_student_event_id: 901, meetup_volunteer_event_id: 902) }

      it 'is false' do
        event.should_not be_at_limit
      end
    end
  end

  describe "#reorder_waitlist!" do
    before do
      @event = create(:event,  student_rsvp_limit: 2)
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

  describe "#rsvps_with_checkins" do
    before do
      @event = create(:event)
      @first_session = @event.event_sessions.first
      @first_session.update_attributes(ends_at: 6.months.from_now)

      @last_session = create(:event_session, event: @event, ends_at: 1.year.from_now)

      @rsvp1 = create(:rsvp, event: @event)
      create(:rsvp_session, event_session: @first_session, rsvp: @rsvp1, checked_in: true)

      @rsvp2 = create(:rsvp, event: @event)
      create(:rsvp_session, event_session: @last_session, rsvp: @rsvp2)

      @rsvp3 = create(:rsvp, event: @event)
      create(:rsvp_session, event_session: @last_session, rsvp: @rsvp3, checked_in: true)

      @event.reload
    end

    it 'counts attendances for the last session' do
      attendee_rsvp_data = @event.rsvps_with_checkins
      attendee_rsvp_data.length.should == 3

      workshop_attendees = attendee_rsvp_data.map { |rsvp| [rsvp['id'], rsvp['checked_in_session_ids']] }
      workshop_attendees.should =~ [
        [@rsvp1.id, [@first_session.id]],
        [@rsvp2.id, []],
        [@rsvp3.id, [@last_session.id]]
      ]
    end
  end
  
  describe "waitlists" do
    before do
      @event = create(:event,  student_rsvp_limit: 2)
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

  describe "methods for presenting dietary restrictions" do
      before do
        @event = create(:event)
        @rsvp = create(:rsvp, event: @event)
        @rsvp2 = create(:rsvp, event: @event, dietary_info: "No sea urchins")
        create(:dietary_restriction, restriction: "gluten-free", rsvp: @rsvp )
        create(:dietary_restriction, restriction: "vegan", rsvp: @rsvp )
        create(:dietary_restriction, restriction: "vegan", rsvp: @rsvp2 )
      end

    describe "#dietary_restrictions_totals" do
      it "should return the total for each dietary restrictions" do
        @event.dietary_restrictions_totals.should == {"gluten-free" => 1, "vegan" => 2}
      end
    end

    describe "#other_dietary_restrictions" do
      it "should returns an array of dietary restrictions" do
        expect(@event.other_dietary_restrictions).to eq(["Paleo", "No sea urchins"])
      end
    end

  end
end
