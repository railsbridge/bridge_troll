require 'rails_helper'

describe ReminderSender do
  describe '.send_all' do
    it 'sends reminders for each of the upcoming events' do
      upcoming_event = create(:event, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
      past_event = create(:event)
      past_event.event_sessions.first.update(starts_at: 2.days.ago, ends_at: 1.day.ago)

      expect(ReminderSender).to receive(:remind_attendees_for_event).once.with(upcoming_event)

      ReminderSender.send_all_reminders
    end
  end

  describe '.remind_attendees_for_event' do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    let!(:rsvp) { create(:volunteer_rsvp, event: event) }
    let!(:student_rsvp) { create(:student_rsvp, event: event) }
    let!(:reminded_rsvp) { create(:volunteer_rsvp, reminded_at: Time.now, event: event) }
    let!(:waitlisted_rsvp) { create(:student_rsvp, waitlist_position: 1, event: event) }

    it 'sends emails to all the students' do
      pending_reminder_count = event.rsvps.confirmed.where('reminded_at IS NULL').count
      expect(pending_reminder_count).to be >= 0

      expect {
        ReminderSender.remind_attendees_for_event(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(pending_reminder_count)

      expect {
        ReminderSender.remind_attendees_for_event(event)
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end

    describe 'when there is a volunteer-only session occuring before the all-attendees session' do
      before do
        event.event_sessions.first.update(starts_at: 4.days.from_now, ends_at: 5.days.from_now)
        @volunteer_session = create(:event_session, event: event, starts_at: 2.days.from_now, ends_at: 3.days.from_now, required_for_students: false, volunteers_only: true)

        @volunteer_rsvp = create(:volunteer_rsvp, event: event).tap do |rsvp|
          rsvp.rsvp_sessions.create(event_session: @volunteer_session)
        end
      end

      it 'sends volunteers a session reminder' do
        expect(RsvpMailer).to receive(:reminder_for_session).once.and_call_original

        expect {
          ReminderSender.remind_attendees_for_event(event)
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        expect {
          ReminderSender.remind_attendees_for_event(event)
        }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end

describe "querying for events and sessions" do
  before do
    @event_tomorrow = create(:event, starts_at: Time.now + 1.day)
    @event_four_days_away = create(:event, starts_at: Time.now + 4.days)
    @event_past = create(:event)
    @event_past.update(starts_at: 2.days.ago, ends_at: 1.day.ago)
  end

  describe UpcomingEventsQuery do
    let(:events) do
      [].tap do |found_events|
        UpcomingEventsQuery.new.find_each { |e| found_events << e }
      end
    end

    it 'includes only events in the next three days' do
      expect(events).to eq([@event_tomorrow])
    end
  end
end
