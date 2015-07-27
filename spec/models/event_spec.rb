require 'rails_helper'

describe Event do
  before do
    @user = create(:user)
  end

  it { should belong_to(:location) }
  it { should have_many(:rsvps) }
  it { should have_many(:event_sessions) }
  it { should validate_numericality_of(:student_rsvp_limit) }
  it { should validate_numericality_of(:volunteer_rsvp_limit) }

  it { should validate_presence_of(:title) }

  it "validates that there is at least one event session" do
    event = create(:event)
    event.event_sessions.destroy_all
    event.should have(1).error_on(:event_sessions)

    event.event_sessions << build(:event_session)
    event.should be_valid
  end

  it "validates that allowed_operating_system_ids correspond to OperatingSystem records" do
    valid = [nil, [OperatingSystem.first.id, OperatingSystem.last.id]]
    invalid = ['fjord', [], [999999]]

    valid.each do |value|
      event = Event.new(restrict_operating_systems: true, allowed_operating_system_ids: value)
      event.should have(0).errors_on(:allowed_operating_system_ids)
    end

    invalid.each do |value|
      event = Event.new(restrict_operating_systems: true, allowed_operating_system_ids: value)
      event.should have(1).errors_on(:allowed_operating_system_ids)
    end
  end

  it "sorts event_sessions by ends_at" do
    event = create(:event)

    session2 = event.event_sessions.first
    session2.update_attributes(starts_at: Time.now, ends_at: 1.hour.from_now)
    session3 = create(:event_session, event: event, starts_at: 20.days.from_now, ends_at: 21.days.from_now)
    session1 = create(:event_session, event: event)
    session1.update_attributes(starts_at: 10.days.ago, ends_at: 9.days.ago)

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
    describe 'decreasing the student RSVP limit' do
      before do
        @event = create(:event, student_rsvp_limit: 5)
        2.times { create(:student_rsvp, event: @event) }
        create(:volunteer_rsvp, event: @event)
        @event.reload
      end

      it 'is allowed if the new limit is greater than or equal to the current number of attendees' do
        @event.update_attributes(student_rsvp_limit: 2)
        @event.should have(0).errors_on(:student_rsvp_limit)
      end

      it 'is disallowed if anyone would be kicked out of the workshop' do
        @event.update_attributes(student_rsvp_limit: 1)
        @event.should have(1).errors_on(:student_rsvp_limit)
      end

      it 'is disallowed if the proposed limit is empty' do
        @event.update_attributes(student_rsvp_limit: 0)
        @event.should have(2).errors_on(:student_rsvp_limit)
      end
    end

    it "does allow student_rsvp_limit to be increased" do
      event = create(:event, volunteer_rsvp_limit: 10)
      event.update_attributes(volunteer_rsvp_limit: 20)
      event.should have(0).errors_on(:volunteer_rsvp_limit)
    end

    it "does allow volunteer_rsvp_limit to be increased" do
      event = create(:event, student_rsvp_limit: 10)
      event.update_attributes(student_rsvp_limit: 20)
      event.should have(0).errors_on(:student_rsvp_limit)
    end

    it "reorders the waitlist" do
      waitlist_manager = double(:waitlist_manager, reorder_waitlist!: true)
      allow(WaitlistManager).to receive(:new).and_return(waitlist_manager)

      event = create(:event, student_rsvp_limit: 10)

      waitlist_manager.should_receive(:reorder_waitlist!)
      event.update_attributes(student_rsvp_limit: 200)
    end
  end

  describe '#location_name' do
    context 'location is set' do
      let(:event) { build(:event, location: build(:location, name: 'FUNZONE!')) }
      it 'returns the name of the location' do
        event.location_name.should eq('FUNZONE!')
      end
    end

    context 'location is nil' do
      let(:event) { build(:event, location: nil) }
      it 'returns an empty string' do
        event.location_name.should eq('')
      end
    end
  end

  describe '#rsvps_with_childcare' do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    let!(:volunteer_rsvp) { create(:volunteer_rsvp, event: event) }
    let!(:student_rsvp) { create(:student_rsvp, event: event) }
    let!(:waitlisted_rsvp) { create(:student_rsvp, event: event, waitlist_position: 1) }

    it 'includes all confirmed rsvps with childcare requested' do
      event.rsvps.count.should == 3
      event.rsvps_with_childcare.should match_array([student_rsvp, volunteer_rsvp])
    end
  end

  describe '#starts_at, #ends_at' do
    it 'populates from the event_session when creating an event+session together' do
      next_year = DateTime.current.year + 1
      event = Event.create(
        title: "Amazingly Sessioned Event",
        details: "This is note in the details attribute.",
        time_zone: "Hawaii",
        published: true,
        student_rsvp_limit: 100,
        volunteer_rsvp_limit: 75,
        course_id: Course::RAILS.id,
        volunteer_details: "I am some details for volunteers.",
        student_details: "I am some details for students.",
        event_sessions_attributes: {
          "0" => {
            name: "My Amazing Session",
            required_for_students: "1",
            "starts_at(1i)" => next_year.to_s,
            "starts_at(2i)" => "01",
            "starts_at(3i)" => "12",
            "starts_at(4i)" => "15",
            "starts_at(5i)" => "15",
            "ends_at(1i)" => next_year.to_s,
            "ends_at(2i)" => "01",
            "ends_at(3i)" => "12",
            "ends_at(4i)" => "17",
            "ends_at(5i)" => "45"
          }
        }
      )
      event.starts_at.should == event.event_sessions.first.starts_at
      event.ends_at.should == event.event_sessions.first.ends_at
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
      create(:student_rsvp, :user => @user, :event => event, waitlist_position: 1)
      event.waitlisted_student?(@user).should == true
    end

    it "returns false when a user is not waitlisted" do
      create(:student_rsvp, :user => @user, :event => event)
      event.waitlisted_student?(@user).should == false
    end
  end

  describe "#waitlisted_volunteer?" do
    let(:event) { create(:event) }

    it "returns true when a user is a waitlisted volunteer" do
      create(:volunteer_rsvp, :user => @user, :event => event, waitlist_position: 1)
      event.waitlisted_volunteer?(@user).should == true
    end

    it "returns false when a user is not waitlisted" do
      create(:volunteer_rsvp, :user => @user, :event => event)
      event.waitlisted_volunteer?(@user).should == false
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
      @event_past = create(:event)
      @event_past.event_sessions.first.update_attributes(
        starts_at: 4.weeks.ago, ends_at: 3.weeks.ago
      )

      @event_future = create(:event)
      @event_future.event_sessions.first.update_attributes(
        starts_at: 3.weeks.from_now, ends_at: 4.weeks.from_now
      )

      @event_in_progress = create(:event)
      @event_in_progress.event_sessions.first.update_attributes(
        starts_at: 2.days.ago, ends_at: 2.days.from_now
      )
    end

    it "includes events that have not already ended" do
      Event.upcoming.to_a.map(&:id).should == [@event_in_progress.id, @event_future.id]
    end
  end

  describe ".drafted_by" do
    before do
      @drafted_event = create(:event, title: 'draft saved event', draft_saved: true, published: false)
      @not_drafted_event = create(:event, title: 'draft saved event', draft_saved: true, published: true)
      @user = create(:user)
      @drafted_event.organizers << @user
      @not_drafted_event.organizers << @user
    end

    it 'returns only the event in draft, unpublished, state' do
      Event.drafted_by(@user).should =~ [@drafted_event]
    end
  end

  describe ".current_state" do
    before do
      @drafted_event = create(:event, title: 'draft saved event', draft_saved: true, published: false)
      @not_drafted_event = create(:event, title: 'draft saved event', draft_saved: true, published: true)
      @user = create(:user)
      @drafted_event.organizers << @user
      @not_drafted_event.organizers << @user
    end

    it 'identifies state correctly' do
      @drafted_event.current_state.should eq :draft_saved
      @not_drafted_event.current_state.should eq :published
    end
  end

  describe ".published_or_organized_by" do
    before do
      @published_event = create(:event, title: 'published event', published: true)
      @unpublished_event = create(:event, title: 'unpublished event', published: false)
      @organized_event = create(:event, title: 'organized event', published: false)
    end

    context "when a user is not provided" do
      it 'returns only published events' do
        Event.published_or_organized_by.should =~ [@published_event]
      end
    end

    context "when the organizer of an event is provided" do
      before do
        @organizer = create(:user)
        @organized_event.organizers << @organizer
      end

      it "returns published events and the organizer's event" do
        Event.published_or_organized_by(@organizer).should =~ [@published_event, @organized_event]
      end
    end

    context "when an admin is provided" do
      before do
        @admin = create(:user, admin: true)
      end

      it "returns all events" do
        Event.published_or_organized_by(@admin).should =~ [@published_event, @unpublished_event, @organized_event]
      end
    end
  end

  describe "#details" do
    it "has default content" do
      Event.new.details.should =~ /Workshop Description/
    end
  end

  describe "#students_at_limit?" do
    context "when the event has a student limit" do
      let(:event) { create(:event, student_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect {
          3.times { create(:student_rsvp, event: event) }
        }.to change { event.reload.students_at_limit? }.from(false).to(true)
      end
    end

    context "when the event has no limit (historical events)" do
      let(:event) { create(:event, student_rsvp_limit: nil, meetup_student_event_id: 901, meetup_volunteer_event_id: 902) }

      it 'is false' do
        event.should_not be_students_at_limit
      end
    end
  end

  describe "#volunteers_at_limit?" do
    context "when the event has a volunteer limit" do
      let(:event) { create(:event, volunteer_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect {
          3.times { create(:volunteer_rsvp, event: event) }
        }.to change { event.reload.volunteers_at_limit? }.from(false).to(true)
      end
    end

    context "when the event has no limit (historical events)" do
      let(:event) { create(:event, volunteer_rsvp_limit: nil, meetup_student_event_id: 901, meetup_volunteer_event_id: 902) }

      it 'is false' do
        event.should_not be_volunteers_at_limit
      end
    end
  end

  describe "#volunteers_at_limit?" do
    context "when the event has a volunteer limit" do
      let(:event) { create(:event, volunteer_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect {
          3.times { create(:volunteer_rsvp, event: event) }
        }.to change { event.reload.volunteers_at_limit? }.from(false).to(true)
      end
    end

    context "when the event has no limit (historical events)" do
      let(:event) { create(:event, volunteer_rsvp_limit: nil, meetup_student_event_id: 901, meetup_volunteer_event_id: 902) }

      it 'is false' do
        event.should_not be_volunteers_at_limit
      end
    end
  end

  describe "#students" do
    before do
      @event = create(:event)
      @volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @confirmed_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT, waitlist_position: 1)
    end

    it 'should only include non-waitlisted students' do
      @event.students.should == [@confirmed_rsvp.user]
    end
  end

  describe "#volunteers" do
    before do
      @event = create(:event)
      @confirmed_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::VOLUNTEER, waitlist_position: 1)
      @student_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
    end

    it 'should only include non-waitlisted volunteers' do
      @event.volunteers.should == [@confirmed_rsvp.user]
    end
  end

  describe "#rsvps_with_checkins" do
    before do
      @event = create(:event)
      @first_session = @event.event_sessions.first
      @first_session.update_attributes(ends_at: 6.months.from_now)

      @last_session = create(:event_session, event: @event, ends_at: 1.year.from_now)

      @rsvp1 = create(:student_rsvp, event: @event, session_checkins: {@first_session.id => true, @last_session.id => false})

      @rsvp2 = create(:student_rsvp, event: @event, session_checkins: {@first_session.id => false, @last_session.id => false})

      @rsvp3 = create(:student_rsvp, event: @event, session_checkins: {@first_session.id => false, @last_session.id => true})

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

    it 'includes RSVPs that are waitlisted but checked in' do
      @event.update_attributes(student_rsvp_limit: @event.student_rsvps.count)
      @checked_in = create(:student_rsvp, event: @event, waitlist_position: 1)
      @checked_in.rsvp_sessions.find { |rs| rs.event_session_id = @last_session.id }.update_attribute(:checked_in, true)
      @not_checked_in = create(:student_rsvp, event: @event, waitlist_position: 2)

      rsvp_ids = @event.rsvps_with_checkins.map { |r| r['id'] }
      expect(rsvp_ids).to match_array([@rsvp1, @rsvp2, @rsvp3, @checked_in].map(&:id))
    end
  end

  describe "#checkin_counts" do
    before do
      @event = create(:event)
      @event.update_attribute(:student_rsvp_limit, 2)
      @session1 = @event.event_sessions.first
      @session2 = create(:event_session, event: @event)

      def deep_copy(o)
        Marshal.load(Marshal.dump(o))
      end

      expectation = {
        Role::VOLUNTEER.id => {
          @session1.id => [],
          @session2.id => []
        },
        Role::STUDENT.id => {
          @session1.id => [],
          @session2.id => []
        }
      }
      @rsvps = deep_copy(expectation)
      @checkins = deep_copy(expectation)

      def add_rsvp(factory, session_checkins, additional_rsvp_options = {})
        rsvp_options = {
          event: @event,
          session_checkins: session_checkins
        }.merge(additional_rsvp_options)

        create(factory, rsvp_options).tap do |rsvp|
          next if additional_rsvp_options[:waitlist_position]

          session_checkins.each do |session_id, checked_in|
            @rsvps[rsvp.role.id][session_id] << rsvp
            @checkins[rsvp.role.id][session_id] << rsvp if checked_in
          end
        end
      end

      add_rsvp(:volunteer_rsvp, {@session1.id => true, @session2.id => true})
      add_rsvp(:volunteer_rsvp, {@session1.id => true, @session2.id => false})
      add_rsvp(:volunteer_rsvp, {@session1.id => true})
      add_rsvp(:student_rsvp, {@session2.id => true})
      add_rsvp(:student_rsvp, {@session2.id => true})
      add_rsvp(:student_rsvp, {@session2.id => false}, waitlist_position: 1)
    end

    it "sends checked in user counts to the view" do
      checkin_counts = @event.checkin_counts
      checkin_counts[Role::VOLUNTEER.id][:rsvp].should == {
        @session1.id => @rsvps[Role::VOLUNTEER.id][@session1.id].length,
        @session2.id => @rsvps[Role::VOLUNTEER.id][@session2.id].length
      }
      checkin_counts[Role::VOLUNTEER.id][:checkin].should == {
        @session1.id => @checkins[Role::VOLUNTEER.id][@session1.id].length,
        @session2.id => @checkins[Role::VOLUNTEER.id][@session2.id].length
      }

      checkin_counts[Role::STUDENT.id][:rsvp].should == {
        @session1.id => @rsvps[Role::STUDENT.id][@session1.id].length,
        @session2.id => @rsvps[Role::STUDENT.id][@session2.id].length
      }
      checkin_counts[Role::STUDENT.id][:checkin].should == {
        @session1.id => @checkins[Role::STUDENT.id][@session1.id].length,
        @session2.id => @checkins[Role::STUDENT.id][@session2.id].length
      }
    end
  end

  describe "waitlists" do
    before do
      @event = create(:event, student_rsvp_limit: 2, volunteer_rsvp_limit: 2)
      @confirmed_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT, waitlist_position: 1)
      @confirmed_volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @waitlist_volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER, waitlist_position: 1)
    end

    it "returns only confirmed rsvps in #student_rsvps" do
      @event.student_rsvps.reload.should == [@confirmed_rsvp]
    end

    it "returns only confirmed rsvps in #volunteer_rsvps" do
      @event.volunteer_rsvps.reload.should == [@confirmed_volunteer_rsvp]
    end

    it "returns only waitlisted rsvps in #student_waitlist_rsvps" do
      @event.student_waitlist_rsvps.reload.should == [@waitlist_rsvp]
    end

    it "returns only waitlisted rsvps in #volunteer_waitlist_rsvps" do
      @event.volunteer_waitlist_rsvps.reload.should == [@waitlist_volunteer_rsvp]
    end
  end

  describe "methods for presenting dietary restrictions" do
    before do
      @event = create(:event, student_rsvp_limit: 2)
      @rsvp = create(:rsvp,  event: @event, dietary_info: "Paleo")
      @rsvp2 = create(:rsvp, event: @event, dietary_info: "No sea urchins")
      @waitlisted = create(:rsvp, event: @event, dietary_info: "Pizza only", waitlist_position: 1)
      create(:dietary_restriction, restriction: "gluten-free", rsvp: @rsvp)
      create(:dietary_restriction, restriction: "vegan", rsvp: @rsvp)
      create(:dietary_restriction, restriction: "vegan", rsvp: @rsvp2)
      create(:dietary_restriction, restriction: "vegan", rsvp: @waitlisted)
    end

    describe "#dietary_restrictions_totals" do
      it "should return the total for each dietary restrictions for confirmed attendees" do
        @event.dietary_restrictions_totals.should == { "gluten-free" => 1, "vegan" => 2 }
      end
    end

    describe "#other_dietary_restrictions" do
      it "should returns an array of dietary restrictions" do
        expect(@event.other_dietary_restrictions).to eq(["Paleo", "No sea urchins"])
      end
    end
  end

  describe '#meetup_url' do
    let(:event) { create(:event, meetup_student_event_id: 71323202) }

    it 'creates the URL for a known meetup event' do
      expect(event.meetup_url(event.meetup_student_event_id)).to eq('http://www.meetup.com/Los-Angeles-Womens-Ruby-on-Rails-Group/events/71323202/')
    end
  end
end
