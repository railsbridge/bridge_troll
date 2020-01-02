# frozen_string_literal: true

require 'rails_helper'

describe Event do
  before do
    @user = create(:user)
  end

  it { is_expected.to belong_to(:location).optional }
  it { is_expected.to have_many(:rsvps) }
  it { is_expected.to have_many(:event_sessions) }
  it { is_expected.to validate_numericality_of(:student_rsvp_limit).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:volunteer_rsvp_limit).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:title) }

  describe 'validations' do
    describe 'target_audience' do
      subject { described_class.new }

      before { allow(subject).to receive(:allow_student_rsvp?).and_return(true) }

      it { is_expected.to validate_presence_of(:target_audience) }

      context 'when event is not a workshop' do
        before { allow(subject).to receive(:allow_student_rsvp?).and_return(false) }

        it { is_expected.not_to validate_presence_of(:target_audience) }
      end

      context 'when event is not a new event and never had target_audience set' do
        before do
          allow(subject).to receive(:new_record?).and_return(false)
          allow(subject).to receive(:target_audience_was).and_return(false)
        end

        it { is_expected.not_to validate_presence_of(:target_audience) }
      end
    end

    it 'event_sessions' do
      event = create(:event)
      event.event_sessions.destroy_all
      expect(event).to have(1).error_on(:event_sessions)

      event.event_sessions << build(:event_session)
      expect(event).to be_valid
    end

    it 'requires that allowed_operating_system_ids correspond to OperatingSystem records' do
      valid = [nil, [OperatingSystem.first.id, OperatingSystem.last.id]]
      invalid = ['fjord', [], [999_999]]

      valid.each do |value|
        event = described_class.new(restrict_operating_systems: true, allowed_operating_system_ids: value)
        expect(event).to have(0).errors_on(:allowed_operating_system_ids)
      end

      invalid.each do |value|
        event = described_class.new(restrict_operating_systems: true, allowed_operating_system_ids: value)
        expect(event).to have(1).errors_on(:allowed_operating_system_ids)
      end
    end
  end

  it 'sorts event_sessions by ends_at' do
    event = create(:event)

    session2 = event.event_sessions.first
    session2.update(starts_at: Time.zone.now, ends_at: 1.hour.from_now)
    session3 = create(:event_session, event: event, starts_at: 20.days.from_now, ends_at: 21.days.from_now)
    session1 = create(:event_session, event: event)
    session1.update(starts_at: 10.days.ago, ends_at: 9.days.ago)

    expect(event.reload.event_sessions).to eq([session1, session2, session3])
  end

  it 'must have a time zone' do
    event = build(:event, time_zone: nil)
    expect(event).to have(1).error_on(:time_zone)
  end

  it 'must have a valid time zone' do
    event = build(:event, time_zone: 'xxx')
    expect(event).to have(1).error_on(:time_zone)

    event = build(:event, time_zone: 'Hawaii')
    expect(event).to have(0).errors
  end

  describe 'updating an event' do
    describe 'decreasing the student RSVP limit' do
      before do
        @event = create(:event, student_rsvp_limit: 5)
        create_list(:student_rsvp, 2, event: @event)
        create(:volunteer_rsvp, event: @event)
        @event.reload
      end

      it 'is allowed if the new limit is greater than or equal to the current number of attendees' do
        @event.update(student_rsvp_limit: 2)
        expect(@event).to have(0).errors_on(:student_rsvp_limit)
      end

      it 'is disallowed if anyone would be kicked out of the workshop' do
        @event.update(student_rsvp_limit: 1)
        expect(@event).to have(1).errors_on(:student_rsvp_limit)
      end

      it 'is disallowed if the proposed limit is empty' do
        @event.update(student_rsvp_limit: 0)
        expect(@event).to have(2).errors_on(:student_rsvp_limit)
      end
    end

    it 'does allow student_rsvp_limit to be increased' do
      event = create(:event, volunteer_rsvp_limit: 10)
      event.update(volunteer_rsvp_limit: 20)
      expect(event).to have(0).errors_on(:volunteer_rsvp_limit)
    end

    it 'does allow volunteer_rsvp_limit to be increased' do
      event = create(:event, student_rsvp_limit: 10)
      event.update(student_rsvp_limit: 20)
      expect(event).to have(0).errors_on(:student_rsvp_limit)
    end

    it 'reorders the waitlist' do
      waitlist_manager = instance_double(WaitlistManager, reorder_waitlist!: true)
      allow(WaitlistManager).to receive(:new).and_return(waitlist_manager)

      event = create(:event, student_rsvp_limit: 10)

      expect(waitlist_manager).to receive(:reorder_waitlist!)
      event.update(student_rsvp_limit: 200)
    end
  end

  describe '#location_name' do
    context 'location is set' do
      let(:event) { build(:event, location: build(:location, name: 'FUNZONE!')) }

      it 'returns the name of the location' do
        expect(event.location_name).to eq('FUNZONE!')
      end
    end

    context 'location is nil' do
      let(:event) { build(:event, location: nil) }

      it 'returns an empty string' do
        expect(event.location_name).to eq('')
      end
    end
  end

  describe '#rsvps_with_childcare' do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    let!(:volunteer_rsvp) { create(:volunteer_rsvp, event: event) }
    let!(:student_rsvp) { create(:student_rsvp, event: event) }
    let!(:waitlisted_rsvp) { create(:student_rsvp, event: event, waitlist_position: 1) }

    it 'includes all confirmed rsvps with childcare requested' do
      expect(event.rsvps.count).to eq(3)
      expect(event.rsvps_with_childcare).to match_array([student_rsvp, volunteer_rsvp])
    end
  end

  describe '#starts_at, #ends_at' do
    it 'populates from the event_session when creating an event+session together' do
      next_year = DateTime.current.year + 1
      attrs = attributes_for(:event, event_sessions_attributes: {
                               '0' => {
                                 name: 'My Amazing Session',
                                 required_for_students: '1',
                                 'starts_at(1i)' => next_year.to_s,
                                 'starts_at(2i)' => '01',
                                 'starts_at(3i)' => '12',
                                 'starts_at(4i)' => '15',
                                 'starts_at(5i)' => '15',
                                 'ends_at(1i)' => next_year.to_s,
                                 'ends_at(2i)' => '01',
                                 'ends_at(3i)' => '12',
                                 'ends_at(4i)' => '17',
                                 'ends_at(5i)' => '45'
                               }
                             })
      event = described_class.create(attrs.merge(chapter_id: create(:chapter).id))
      expect(event.starts_at).to eq(event.event_sessions.first.starts_at)
      expect(event.ends_at).to eq(event.event_sessions.first.ends_at)
    end
  end

  describe '#volunteer?' do
    let(:event) { create(:event) }

    it 'is true when a user is volunteering at an event' do
      create(:rsvp, user: @user, event: event)
      expect(event.volunteer?(@user)).to eq(true)
    end

    it 'is false when a user is not volunteering at an event' do
      expect(event.volunteer?(@user)).to eq(false)
    end
  end

  describe '#waitlisted_student?' do
    let(:event) { create(:event) }

    it 'returns true when a user is a waitlisted student' do
      create(:student_rsvp, user: @user, event: event, waitlist_position: 1)
      expect(event.waitlisted_student?(@user)).to eq(true)
    end

    it 'returns false when a user is not waitlisted' do
      create(:student_rsvp, user: @user, event: event)
      expect(event.waitlisted_student?(@user)).to eq(false)
    end
  end

  describe '#waitlisted_volunteer?' do
    let(:event) { create(:event) }

    it 'returns true when a user is a waitlisted volunteer' do
      create(:volunteer_rsvp, user: @user, event: event, waitlist_position: 1)
      expect(event.waitlisted_volunteer?(@user)).to eq(true)
    end

    it 'returns false when a user is not waitlisted' do
      create(:volunteer_rsvp, user: @user, event: event)
      expect(event.waitlisted_volunteer?(@user)).to eq(false)
    end
  end

  describe '#rsvp_for_user' do
    it 'returns the rsvp for a user' do
      event = create(:event)
      expect(event.rsvp_for_user(@user)).to eq(event.rsvps.find_by(user_id: @user.id))
    end
  end

  describe '.upcoming' do
    before do
      @event_past = create(:event)
      @event_past.event_sessions.first.update(
        starts_at: 4.weeks.ago, ends_at: 3.weeks.ago
      )

      @event_future = create(:event)
      @event_future.event_sessions.first.update(
        starts_at: 3.weeks.from_now, ends_at: 4.weeks.from_now
      )

      @event_in_progress = create(:event)
      @event_in_progress.event_sessions.first.update(
        starts_at: 2.days.ago, ends_at: 2.days.from_now
      )
    end

    it 'includes events that have not already ended' do
      expect(described_class.upcoming.to_a.map(&:id)).to eq([@event_in_progress.id, @event_future.id])
    end
  end

  describe '.drafted_by' do
    before do
      @drafted_event = create(:event, title: 'draft saved event', current_state: :draft)
      @not_drafted_event = create(:event, title: 'draft saved event', current_state: :published)
      @user = create(:user)
      @drafted_event.organizers << @user
      @not_drafted_event.organizers << @user
    end

    it 'returns only the event in draft, unpublished, state' do
      expect(described_class.drafted_by(@user)).to match_array([@drafted_event])
    end
  end

  describe '.published_or_visible_to' do
    before do
      @published_event = create(:event, title: 'published event', current_state: :published)
      @unpublished_event = create(:event, title: 'unpublished event', current_state: :pending_approval)
      @organized_event = create(:event, title: 'organized event', current_state: :pending_approval)
    end

    context 'when a user is not provided' do
      it 'returns only published events' do
        expect(described_class.published_or_visible_to).to match_array([@published_event])
      end
    end

    context 'when the organizer of an event is provided' do
      before do
        @organizer = create(:user)
        @organized_event.organizers << @organizer
      end

      it "returns published events and the organizer's event" do
        expect(described_class.published_or_visible_to(@organizer)).to match_array([@published_event, @organized_event])
      end
    end

    context 'when a chapter leader is provided' do
      before do
        chapter = create(:chapter)
        @leader = create(:user)
        @chapter_event = create(:event, chapter: chapter, current_state: :pending_approval)
        chapter.leaders << @leader
      end

      it 'returns published events and unpublished events for that chapter' do
        expect(described_class.published_or_visible_to(@leader)).to match_array([@published_event, @chapter_event])
      end
    end

    context 'when an admin is provided' do
      before do
        @admin = create(:user, admin: true)
      end

      it 'returns all events' do
        expect(described_class.published_or_visible_to(@admin)).to match_array([@published_event, @unpublished_event, @organized_event])
      end
    end
  end

  describe '#details' do
    it 'has default content' do
      expect(described_class.new.details).to match(/Workshop Description/)
    end
  end

  describe '#close_rsvps' do
    it 'closes the event' do
      event = create(:event, open: true)
      event.close_rsvps
      expect(event).to be_closed
    end
  end

  describe '#reopen_rsvps' do
    it 'reopens the event' do
      event = create(:event, open: false)
      event.reopen_rsvps
      expect(event).to be_open
    end
  end

  describe '#students_at_limit?' do
    context 'when the event has a student limit' do
      let(:event) { create(:event, student_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect do
          create_list(:student_rsvp, 3, event: event)
        end.to change { event.reload.students_at_limit? }.from(false).to(true)
      end
    end

    context 'when the event has no limit (historical events)' do
      let(:event) do
        create(:event, :imported, student_rsvp_limit: nil)
      end

      it 'is false' do
        expect(event).not_to be_students_at_limit
      end
    end
  end

  describe '#volunteers_at_limit?' do
    context 'when the event has a volunteer limit' do
      let(:event) { create(:event, volunteer_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect do
          create_list(:volunteer_rsvp, 3, event: event)
        end.to change { event.reload.volunteers_at_limit? }.from(false).to(true)
      end
    end

    context 'when the event has no limit (historical events)' do
      let(:event) do
        create(:event, :imported, volunteer_rsvp_limit: nil)
      end

      it 'is false' do
        expect(event).not_to be_volunteers_at_limit
      end
    end
  end

  describe '#volunteers_at_limit?' do
    context 'when the event has a volunteer limit' do
      let(:event) { create(:event, volunteer_rsvp_limit: 2) }

      it 'is true when the limit is exceeded' do
        expect do
          create_list(:volunteer_rsvp, 3, event: event)
        end.to change { event.reload.volunteers_at_limit? }.from(false).to(true)
      end
    end

    context 'when the event has no limit (historical events)' do
      let(:event) do
        create(:event, :imported, volunteer_rsvp_limit: nil)
      end

      it 'is false' do
        expect(event).not_to be_volunteers_at_limit
      end
    end
  end

  describe '#students' do
    before do
      @event = create(:event)
      @volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @confirmed_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT, waitlist_position: 1)
    end

    it 'onlies include non-waitlisted students' do
      expect(@event.students).to eq([@confirmed_rsvp.user])
    end
  end

  describe '#volunteers' do
    before do
      @event = create(:event)
      @confirmed_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::VOLUNTEER, waitlist_position: 1)
      @student_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
    end

    it 'onlies include non-waitlisted volunteers' do
      expect(@event.volunteers).to eq([@confirmed_rsvp.user])
    end
  end

  describe '#rsvps_with_checkins' do
    before do
      @event = create(:event)
      @first_session = @event.event_sessions.first
      @first_session.update(ends_at: 6.months.from_now)

      @last_session = create(:event_session, event: @event, ends_at: 1.year.from_now)

      @rsvp1 = create(:student_rsvp, event: @event, session_checkins: { @first_session.id => true, @last_session.id => false })

      @rsvp2 = create(:student_rsvp, event: @event, session_checkins: { @first_session.id => false, @last_session.id => false })

      @rsvp3 = create(:student_rsvp, event: @event, session_checkins: { @first_session.id => false, @last_session.id => true })

      @event.reload
    end

    it 'counts attendances for the last session' do
      attendee_rsvp_data = @event.rsvps_with_checkins
      expect(attendee_rsvp_data.length).to eq(3)

      workshop_attendees = attendee_rsvp_data.map { |rsvp| [rsvp['id'], rsvp['checked_in_session_ids']] }
      expect(workshop_attendees).to match_array([
                                                  [@rsvp1.id, [@first_session.id]],
                                                  [@rsvp2.id, []],
                                                  [@rsvp3.id, [@last_session.id]]
                                                ])
    end

    it 'includes RSVPs that are waitlisted but checked in' do
      @event.update(student_rsvp_limit: @event.student_rsvps.count)
      @checked_in = create(:student_rsvp, event: @event, waitlist_position: 1)
      @checked_in.rsvp_sessions.find { |rs| rs.event_session_id = @last_session.id }.update_attribute(:checked_in, true)
      @not_checked_in = create(:student_rsvp, event: @event, waitlist_position: 2)

      rsvp_ids = @event.rsvps_with_checkins.map { |r| r['id'] }
      expect(rsvp_ids).to match_array([@rsvp1, @rsvp2, @rsvp3, @checked_in].map(&:id))
    end
  end

  describe '#checkin_counts' do
    before do
      @event = create(:event)
      @event.update_attribute(:student_rsvp_limit, 2)
      @session1 = @event.event_sessions.first
      @session2 = create(:event_session, event: @event)

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
      @rsvps = expectation.deep_dup
      @checkins = expectation.deep_dup

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

      add_rsvp(:volunteer_rsvp, @session1.id => true, @session2.id => true)
      add_rsvp(:volunteer_rsvp, @session1.id => true, @session2.id => false)
      add_rsvp(:volunteer_rsvp, @session1.id => true)
      add_rsvp(:student_rsvp, @session2.id => true)
      add_rsvp(:student_rsvp, @session2.id => true)
      add_rsvp(:student_rsvp, { @session2.id => false }, waitlist_position: 1)
    end

    it 'sends checked in user counts to the view' do
      checkin_counts = @event.checkin_counts
      expect(checkin_counts[Role::VOLUNTEER.id][:rsvp]).to eq(
        @session1.id => @rsvps[Role::VOLUNTEER.id][@session1.id].length,
        @session2.id => @rsvps[Role::VOLUNTEER.id][@session2.id].length
      )
      expect(checkin_counts[Role::VOLUNTEER.id][:checkin]).to eq(
        @session1.id => @checkins[Role::VOLUNTEER.id][@session1.id].length,
        @session2.id => @checkins[Role::VOLUNTEER.id][@session2.id].length
      )

      expect(checkin_counts[Role::STUDENT.id][:rsvp]).to eq(
        @session1.id => @rsvps[Role::STUDENT.id][@session1.id].length,
        @session2.id => @rsvps[Role::STUDENT.id][@session2.id].length
      )
      expect(checkin_counts[Role::STUDENT.id][:checkin]).to eq(
        @session1.id => @checkins[Role::STUDENT.id][@session1.id].length,
        @session2.id => @checkins[Role::STUDENT.id][@session2.id].length
      )
    end
  end

  describe 'waitlists' do
    before do
      @event = create(:event, student_rsvp_limit: 2, volunteer_rsvp_limit: 2)
      @confirmed_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT)
      @waitlist_rsvp = create(:student_rsvp, event: @event, role: Role::STUDENT, waitlist_position: 1)
      @confirmed_volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER)
      @waitlist_volunteer_rsvp = create(:volunteer_rsvp, event: @event, role: Role::VOLUNTEER, waitlist_position: 1)
    end

    it 'returns only confirmed rsvps in #student_rsvps' do
      expect(@event.student_rsvps.reload).to eq([@confirmed_rsvp])
    end

    it 'returns only confirmed rsvps in #volunteer_rsvps' do
      expect(@event.volunteer_rsvps.reload).to eq([@confirmed_volunteer_rsvp])
    end

    it 'returns only waitlisted rsvps in #student_waitlist_rsvps' do
      expect(@event.student_waitlist_rsvps.reload).to eq([@waitlist_rsvp])
    end

    it 'returns only waitlisted rsvps in #volunteer_waitlist_rsvps' do
      expect(@event.volunteer_waitlist_rsvps.reload).to eq([@waitlist_volunteer_rsvp])
    end
  end

  describe 'methods for presenting dietary restrictions' do
    before do
      @event = create(:event, student_rsvp_limit: 2)
      @rsvp = create(:rsvp,  event: @event, dietary_info: 'Paleo')
      @rsvp2 = create(:rsvp, event: @event, dietary_info: 'No sea urchins', checked_in: true)
      @waitlisted = create(:rsvp, event: @event, dietary_info: 'Pizza only', waitlist_position: 1)
      create(:dietary_restriction, restriction: 'gluten-free', rsvp: @rsvp)
      create(:dietary_restriction, restriction: 'vegan', rsvp: @rsvp)
      create(:dietary_restriction, restriction: 'vegan', rsvp: @rsvp2)
      create(:dietary_restriction, restriction: 'vegan', rsvp: @waitlisted)
    end

    describe '#dietary_restrictions_totals' do
      it 'returns the total for each dietary restrictions for confirmed attendees' do
        expect(@event.dietary_restrictions_totals).to eq('gluten-free' => 1, 'vegan' => 2)
      end
    end

    describe '#other_dietary_restrictions' do
      it 'returns an array of dietary restrictions' do
        expect(@event.other_dietary_restrictions).to match_array(['Paleo', 'No sea urchins'])
      end
    end

    describe '#checked_in_attendees_dietary_restrictions_totals' do
      it 'returns the total for each dietary restriction for checked-in attendees' do
        expect(@event.checked_in_attendees_dietary_restrictions_totals).to eq('vegan' => 1)
      end
    end

    describe '#checked_in_attendees_other_dietary_restrictions' do
      it "returns an array of checked in attendees' dietary restrictions" do
        expect(@event.checked_in_attendees_other_dietary_restrictions).to eq(['No sea urchins'])
      end
    end
  end

  describe '#asks_custom_question?' do
    context 'when event asks a custom question' do
      before do
        allow(subject).to receive(:custom_question).and_return('What is your t-shirt size?')
      end

      it 'returns true' do
        expect(subject.asks_custom_question?).to be true
      end
    end

    context 'when event does not ask a custom question' do
      before do
        allow(subject).to receive(:custom_question).and_return('')
      end

      it 'returns false' do
        expect(subject.asks_custom_question?).to be false
      end
    end
  end
end
