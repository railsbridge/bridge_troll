require 'rails_helper'

describe Rsvp do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:event) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:event) }

  describe 'confirmed scope' do
    before do
      @confirmed = create :rsvp
      @unconfirmed = create :student_rsvp, waitlist_position: 1
    end

    it 'includes only rsvps that arent on the WL' do
      expect(Rsvp.confirmed).to include(@confirmed)
      expect(Rsvp.confirmed).to_not include(@unconfirmed)
    end
  end

  describe 'needs_childcare scope' do
    before do
      @needs_childcare = create :rsvp
      @no_childcare = create :rsvp, childcare_info: nil
    end

    it 'includes only rsvps that requested childcare' do
      expect(Rsvp.needs_childcare).to include(@needs_childcare)
      expect(Rsvp.needs_childcare).to_not include(@no_childcare)
    end
  end

  context 'for volunteers' do
    subject { build(:rsvp) }

    it { is_expected.to validate_presence_of(:subject_experience) }
    it { is_expected.to validate_length_of(:subject_experience).is_at_most(250).is_at_least(10) }

    it "should only require class_level if teaching or TAing" do
      expect(subject.class_level).to be_nil
      expect(subject).to have(0).errors_on(:class_level)

      subject.teaching = true
      expect(subject).to have(1).errors_on(:class_level)
      expect(subject).to validate_inclusion_of(:class_level).in_range(0..5)
    end

    it "should only require teaching_experience if teaching or TAing" do
      expect(subject.teaching).to be false
      expect(subject).not_to validate_presence_of(:teaching_experience)

      subject.teaching = true
      expect(subject).to validate_presence_of(:teaching_experience)
      expect(subject).to validate_length_of(:teaching_experience).is_at_least(10).is_at_most(250)
    end

    it "allows rsvps from the same user ID but different user type" do
      @event = create(:event)
      @bridgetroll_user = create(:user, id: 2001)
      @meetup_user = create(:meetup_user, id: 2001)
      rsvp1 = create(:rsvp, user: @bridgetroll_user, event: @event, role: Role::VOLUNTEER)
      rsvp2 = create(:rsvp, user: @meetup_user, event: @event, role: Role::VOLUNTEER)
      expect(rsvp1).to be_valid
      expect(rsvp2).to be_valid
    end
  end

  describe '#no_show?' do
    it 'is always false for a historical rsvp' do
      historical_event = create(:event, meetup_volunteer_event_id: 1234, meetup_student_event_id: 4321)

      rsvp = create(:rsvp, user: create(:meetup_user), event: historical_event)
      expect(rsvp).not_to be_no_show

      rsvp = create(:rsvp, user: create(:user), event: historical_event)
      expect(rsvp).not_to be_no_show
    end

    context 'when the event has passed' do
      let(:event) { create(:event) }
      let(:event_session) do
        event.event_sessions.first.tap do |event_session|
          event_session.update_attributes(starts_at: 1.year.ago, ends_at: 6.months.ago)
        end
      end
      let(:rsvp) do
        create(:rsvp, event: event, session_checkins: {event_session.id => checked_in})
      end

      context 'when the user has checked in' do
        let(:checked_in) { true }

        it 'is false' do
          expect(rsvp.reload).not_to be_no_show
        end
      end

      context 'when the user has not checked in' do
        let(:checked_in) { false }

        it 'is true' do
          expect(rsvp.reload).to be_no_show
        end
      end
    end

    context 'when the event has not passed' do
      it 'is always false' do
        event = create(:event)
        event.event_sessions.first.update_attributes(starts_at: 1.year.from_now, ends_at: 2.years.from_now)

        rsvp = create(:rsvp, user: create(:user), event: event)
        expect(rsvp).not_to be_no_show
      end
    end
  end

  describe "#selectable_sessions" do
    let(:event) do
      build(:event_with_no_sessions).tap do |event|
        @session_no_options = build(:event_session, event: event, required_for_students: false, volunteers_only: false)
        event.event_sessions << @session_no_options
        event.save!
      end
    end

    before do
      @session_required_for_students = create(:event_session, event: event, required_for_students: true, volunteers_only: false)
      @session_volunteers_only = create(:event_session, event: event, required_for_students: false, volunteers_only: true)
    end

    describe "for students" do
      let(:rsvp) { create(:student_rsvp, event: event) }

      it "returns only those sessions which are not marked as volunteer only" do
        expect(rsvp.selectable_sessions.pluck(:id)).to match_array([@session_no_options.id, @session_required_for_students.id])
      end
    end

    describe "for volunteers" do
      let(:rsvp) { create(:volunteer_rsvp, event: event) }

      it "returns all sessions" do
        expect(rsvp.selectable_sessions.pluck(:id)).to match_array([@session_no_options.id, @session_required_for_students.id, @session_volunteers_only.id])
      end
    end

    describe "for organizers" do
      let(:rsvp) { create(:organizer_rsvp, event: event) }

      it "raises an error" do
        expect { rsvp.selectable_sessions }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#as_json" do
    before do
      @user = create(:user, first_name: 'Bill', last_name: 'Blank')
      @rsvp = create(:rsvp, user: @user)
    end

    it "includes the user's full name" do
      expect(@rsvp.as_json["full_name"]).to eq('Bill Blank')
    end
  end
end
