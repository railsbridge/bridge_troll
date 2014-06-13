require 'rails_helper'

describe ReminderSender do
  describe '.send_all' do
    it 'sends the reminders for each of the upcoming events' do
      upcoming_event = create(:event, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
      past_event = create(:event)
      past_event.event_sessions.first.update_attributes(starts_at: 2.days.ago, ends_at: 1.day.ago)
      ReminderSender.should_receive(:remind_attendees_for).with(upcoming_event)
      ReminderSender.should_not_receive(:remind_attendees_for).with(past_event)
      ReminderSender.send_all_reminders
    end
  end

  describe '.remind_attendees_for' do
    let(:event) { create(:event, student_rsvp_limit: 1) }
    let!(:rsvp) { create(:volunteer_rsvp, event: event) }
    let!(:student_rsvp) { create(:student_rsvp, event: event) }
    let!(:reminded_rsvp) { create(:volunteer_rsvp, reminded_at: Time.now, event: event) }
    let!(:waitlisted_rsvp) { create(:student_rsvp, waitlist_position: 1, event: event) }

    it 'sends emails to all the students' do
      pending_reminder_count = event.rsvps.confirmed.where('reminded_at IS NULL').count
      expect {
        ReminderSender.remind_attendees_for(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(pending_reminder_count)
    end

    it 'updates reminded_at' do
      ReminderSender.remind_attendees_for(event)
      event.reload.rsvps.confirmed.each do |rsvp|
        rsvp.reminded_at.should_not be_nil
      end
    end
  end
end

describe UpcomingEventsQuery do
  let(:events) { UpcomingEventsQuery.new }

  it 'includes events in the next three days' do
    event_tomorrow = create(:event, starts_at: Time.now + 1.day)
    found = false
    events.find_each { |event| found = true if event_tomorrow == event }
    found.should be true
  end

  it 'doesnt include events in the far future' do
    event_four_days_away = create(:event, starts_at: Time.now + 4.days)
    events.find_each { |event| event.should_not eq(event_four_days_away) }
  end

  it 'doesnt include events in the past' do
    past_event = create(:event)
    past_event.update_attributes(starts_at: 2.days.ago, ends_at: 1.day.ago)
    events.find_each { |event| event.should_not eq(past_event) }
  end
end