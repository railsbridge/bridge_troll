require 'rails_helper'

describe Rsvp do
  it { should belong_to(:user) }
  it { should belong_to(:event) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:event) }

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

    it { should validate_presence_of(:subject_experience) }
    it { should ensure_length_of(:subject_experience).is_at_most(250).is_at_least(10) }

    it "should only require class_level if teaching or TAing" do
      subject.class_level.should be_nil
      subject.should be_valid

      subject.teaching = true
      subject.should have(1).errors_on(:class_level)
      subject.should validate_inclusion_of(:class_level).in_range(0..5)
    end

    it "should only require teaching_experience if teaching or TAing" do
      subject.teaching.should be false
      subject.should_not validate_presence_of(:teaching_experience)

      subject.teaching = true
      subject.should validate_presence_of(:teaching_experience)
      subject.should ensure_length_of(:teaching_experience).is_at_least(10).is_at_most(250)
    end

    it "allows rsvps from the same user ID but different user type" do
      @event = create(:event)
      @bridgetroll_user = create(:user, id: 2001)
      @meetup_user = create(:meetup_user, id: 2001)
      rsvp1 = create(:rsvp, user: @bridgetroll_user, event: @event, role: Role::VOLUNTEER)
      rsvp2 = create(:rsvp, user: @meetup_user, event: @event, role: Role::VOLUNTEER)
      rsvp1.should be_valid
      rsvp2.should be_valid
    end
  end

  describe '#no_show?' do
    it 'is always false for a historical rsvp' do
      historical_event = create(:event, meetup_volunteer_event_id: 1234, meetup_student_event_id: 4321)

      rsvp = create(:rsvp, user: create(:meetup_user), event: historical_event)
      rsvp.should_not be_no_show

      rsvp = create(:rsvp, user: create(:user), event: historical_event)
      rsvp.should_not be_no_show
    end

    context 'when the event has passed' do
      let(:event) { create(:event) }
      before do
        event.event_sessions.first.update_attributes(starts_at: 1.year.ago, ends_at: 6.months.ago)
      end

      it 'is false if the user got checked in to any sessions' do
        rsvp = create(:rsvp, user: create(:user), event: event)
        rsvp.rsvp_sessions.create(checked_in: true)
        rsvp.save!
        rsvp.reload.should_not be_no_show
      end

      it 'is true if the user was never checked in' do
        rsvp = create(:rsvp, user: create(:user), event: event)
        rsvp.rsvp_sessions.create(checked_in: false)
        rsvp.save!
        rsvp.should be_no_show
      end
    end

    context 'when the event has not passed' do
      it 'is always false' do
        event = create(:event)
        event.event_sessions.first.update_attributes(starts_at: 1.year.from_now, ends_at: 2.years.from_now)

        rsvp = create(:rsvp, user: create(:user), event: event)
        rsvp.should_not be_no_show
      end
    end
  end

  describe '#promote_from_waitlist!' do
    let(:rsvp) {
      create(:student_rsvp, waitlist_position: 1)
    }

    it 'marks the rsvp as not on waitlist' do
      expect {
        rsvp.promote_from_waitlist!
      }.to change(rsvp, :waitlist_position).to nil
    end

    it 'sends an email' do
      expect {
        rsvp.promote_from_waitlist!
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
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
        rsvp.selectable_sessions.pluck(:id).should =~ [@session_no_options.id, @session_required_for_students.id]
      end
    end

    describe "for volunteers" do
      let(:rsvp) { create(:volunteer_rsvp, event: event) }

      it "returns all sessions" do
        rsvp.selectable_sessions.pluck(:id).should =~ [@session_no_options.id, @session_required_for_students.id, @session_volunteers_only.id]
      end
    end
  end

  describe "#as_json" do
    before do
      @user = create(:user, first_name: 'Bill', last_name: 'Blank')
      @rsvp = create(:rsvp, user: @user)
    end

    it "includes the user's full name" do
      @rsvp.as_json["full_name"].should == 'Bill Blank'
    end
  end
end
