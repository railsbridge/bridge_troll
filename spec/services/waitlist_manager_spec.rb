# frozen_string_literal: true

require 'rails_helper'

describe WaitlistManager do
  describe '#reorder_waitlist!' do
    context 'for a workshop event' do
      let!(:event) { create(:event, student_rsvp_limit: 2) }
      let!(:confirmed1) { create(:student_rsvp, event: event) }
      let!(:waitlist1) { create(:student_rsvp, event: event, waitlist_position: 1) }
      let!(:waitlist2) { create(:student_rsvp, event: event, waitlist_position: 2) }
      let!(:waitlist3) { create(:student_rsvp, event: event, waitlist_position: 3) }

      before do
        create(:student_rsvp, event: event)
      end

      context 'when the limit has increased' do
        before do
          event.update_attribute(:student_rsvp_limit, 4)
        end

        it 'promotes people on the waitlist into available slots when the limit increases' do
          described_class.new(event).reorder_waitlist!
          event.reload

          expect(event.student_rsvps.count).to eq(4)
          expect(event.student_waitlist_rsvps.count).to eq(1)
        end
      end

      context 'when a confirmed rsvp has been destroyed' do
        before do
          confirmed1.destroy
          described_class.new(event).reorder_waitlist!
        end

        it 'promotes a waitlisted user to confirmed when the rsvp is destroyed' do
          expect(waitlist1.reload.waitlist_position).to be_nil
          expect(waitlist2.reload.waitlist_position).to eq(1)
          expect(waitlist3.reload.waitlist_position).to eq(2)
        end
      end

      context 'when a waitlisted rsvp has been destroyed' do
        before do
          waitlist1.destroy
          described_class.new(event).reorder_waitlist!
        end

        it 'reorders the waitlist when the rsvp is destroyed' do
          expect(waitlist2.reload.waitlist_position).to eq(1)
          expect(waitlist3.reload.waitlist_position).to eq(2)
        end
      end

      context 'when the volunteer waitlist limit is removed' do
        let(:confirmed) { create(:volunteer_rsvp, event: event) }
        let(:waitlist) { create(:volunteer_rsvp, event: event, waitlist_position: 1) }

        before do
          event.update_attribute(:volunteer_rsvp_limit, 1)
          # load confirmed & waitlist rsvps
          confirmed
          waitlist
          event.update_column(:volunteer_rsvp_limit, nil)
        end

        it 'promotes everyone from the volunteer waitlist' do
          described_class.new(event).reorder_waitlist!

          expect(confirmed.reload.waitlist_position).to be_nil
          expect(waitlist.reload.waitlist_position).to be_nil
        end
      end
    end

    context 'for a volunteer-only event' do
      let!(:event) { create(:event, allow_student_rsvp: false, student_rsvp_limit: nil, volunteer_rsvp_limit: 1) }
      let!(:confirmed) { create(:volunteer_rsvp, event: event) }
      let!(:waitlist1) { create(:volunteer_rsvp, event: event, waitlist_position: 1) }
      let!(:waitlist2) { create(:volunteer_rsvp, event: event, waitlist_position: 2) }

      it 'promotes volunteers from the waitlist when the limit is increased' do
        event.update_column(:volunteer_rsvp_limit, 2)

        described_class.new(event).reorder_waitlist!

        expect(confirmed.reload.waitlist_position).to be_nil
        expect(waitlist1.reload.waitlist_position).to be_nil
        expect(waitlist2.reload.waitlist_position).to eq(1)
      end
    end
  end

  describe '#promote_from_waitlist!' do
    let!(:event) { create(:event, student_rsvp_limit: 2) }
    let!(:waitlisted) { create(:student_rsvp, event: event, waitlist_position: 1) }

    before { create(:student_rsvp, event: event) } # confirmed

    it 'removes waitlist_position if there is room' do
      expect do
        described_class.new(event).promote_from_waitlist!(waitlisted)
      end.to change { waitlisted.reload.waitlist_position }.from(1).to(nil)
    end

    it 'sends an email' do
      expect do
        described_class.new(event).promote_from_waitlist!(waitlisted)
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      confirmation_mail = ActionMailer::Base.deliveries.last
      expect(waitlisted.token).to be_truthy
      expect(confirmation_mail.body).to include(waitlisted.token)
    end

    it 'does nothing if there is no room' do
      event.update_attribute(:student_rsvp_limit, 1)

      expect do
        described_class.new(event).promote_from_waitlist!(waitlisted)
      end.not_to(change { waitlisted.reload.waitlist_position })
    end
  end
end
