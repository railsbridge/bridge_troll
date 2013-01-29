require 'spec_helper'

describe Rsvp do
  it { should belong_to(:user) }
  it { should belong_to(:event) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  it { should validate_presence_of(:user)}
  it { should validate_presence_of(:event)}

  describe '#set_attending_sessions' do
    before do
      @event = create(:event)
      @event.event_sessions << create(:event_session)
      @rsvp = create(:rsvp, event: @event)

      @session1 = @event.event_sessions.first
      @session2 = @event.event_sessions.last
    end

    it "allows " do
      expect {
        @rsvp.set_attending_sessions(@event.event_sessions.map(&:id))
      }.to change { @rsvp.rsvp_sessions.count }.by(2)
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
