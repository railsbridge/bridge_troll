require 'spec_helper'

describe Rsvp do
  it { should belong_to(:user) }
  it { should belong_to(:event) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  it { should validate_presence_of(:user)}
  it { should validate_presence_of(:event)}
  
  context 'for volunteers' do
    subject { build(:rsvp) }

    it { should validate_presence_of(:teaching_experience) }
    it { should ensure_length_of(:teaching_experience).is_at_least(10).is_at_most(250) }
    it { should validate_presence_of(:subject_experience)}
    it { should ensure_length_of(:subject_experience).is_at_most(250).is_at_least(10) }

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

  describe '#set_attending_sessions' do
    context "when there is only one event session" do
      before do
        @event = create(:event)
        @event.event_sessions.length.should == 1
        @rsvp = create(:rsvp, event: @event)
      end

      it "creates an rsvp_session record for that session" do
        expect {
          @rsvp.set_attending_sessions
        }.to change { @rsvp.rsvp_sessions.count }.by(1)
        @rsvp.rsvp_sessions.map(&:event_session_id).should =~ @event.event_sessions.map(&:id)
      end
    end

    context "when there are at least two sessions" do
      before do
        @event = create(:event)
        @event.event_sessions << create(:event_session)
        @num_sessions = @event.event_sessions.length
        @rsvp = create(:rsvp, event: @event)

        @session1 = @event.event_sessions.first
        @session2 = @event.event_sessions.last
      end

      it "creates rsvp_session records for all ids sent in" do
        expect {
          @rsvp.set_attending_sessions(@event.event_sessions.map(&:id))
        }.to change { @rsvp.rsvp_sessions.count }.by(@num_sessions)
        @rsvp.rsvp_sessions.map(&:event_session_id).should =~ @event.event_sessions.map(&:id)
      end

      context "when some sessions are already being attended" do
        before do
          create(:rsvp_session, rsvp_id: @rsvp.id, event_session_id: @session1.id)
        end

        it "destroys rsvps when told to set to an empty array" do
          @rsvp.set_attending_sessions([])
          @rsvp.rsvp_sessions.count.should == 0
        end

        it "destroys existing attendance and creates new attendances using the provided ids" do
          @rsvp.set_attending_sessions([@session2.id])
          @rsvp.rsvp_sessions.count.should == 1
          @rsvp.rsvp_sessions.first.event_session.should == @session2
        end
      end
    end
  end
end
