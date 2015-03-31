require 'rails_helper'

describe WaitlistManager do
  describe "#reorder_waitlist!" do
    before do
      @event = create(:event, student_rsvp_limit: 2)
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
        WaitlistManager.new(@event).reorder_waitlist!
        @event.reload

        @event.student_rsvps.count.should == 4
        @event.student_waitlist_rsvps.count.should == 1
      end
    end

    context "when a confirmed rsvp has been destroyed" do
      before do
        @confirmed1.destroy
        WaitlistManager.new(@event).reorder_waitlist!
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
        WaitlistManager.new(@event).reorder_waitlist!
      end

      it 'reorders the waitlist when the rsvp is destroyed' do
        @waitlist2.reload.waitlist_position.should == 1
        @waitlist3.reload.waitlist_position.should == 2
      end
    end
  end

  describe "#promote_from_waitlist!" do
    before do
      @event = create(:event, student_rsvp_limit: 2)
      @confirmed1 = create(:student_rsvp, event: @event)
      @waitlisted = create(:student_rsvp, event: @event, waitlist_position: 1)
    end

    it "removes waitlist_position if there is room" do
      expect {
        WaitlistManager.new(@event).promote_from_waitlist!(@waitlisted)
      }.to change { @waitlisted.reload.waitlist_position }.from(1).to(nil)
    end

    it 'sends an email' do
      expect {
        WaitlistManager.new(@event).promote_from_waitlist!(@waitlisted)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'does nothing if there is no room' do
      @event.update_attribute(:student_rsvp_limit, 1)

      expect {
        WaitlistManager.new(@event).promote_from_waitlist!(@waitlisted)
      }.not_to change { @waitlisted.reload.waitlist_position }
    end
  end
end