require 'spec_helper'

describe ReminderSender do
  describe '.send_all' do
    it 'sends the reminders for each of the upcoming events' do
      upcoming_event = create(:event, starts_at: Time.now + 1.day)
      past_event = create(:event, starts_at: Time.now - 1.day)
      ReminderSender.should_receive(:remind_volunteers_for, upcoming_event)
      ReminderSender.should_not_receive(:remind_volunteers_for).with(past_event)
      ReminderSender.send_all_reminders
    end
  end

  describe '.remind_volunteers_for' do
    let(:event) { create(:event) }
    let!(:volunteer_rsvp) { create(:volunteer_rsvp, :event => event) }
    let!(:reminded_volunteer_rsvp) { create(:volunteer_rsvp, :reminded_at => Time.now, :event => event) }

    it 'sends emails to all the volunteers' do
      pending_reminder_count = event.volunteer_rsvps.where('reminded_at NOT NULL').count
      expect {
        ReminderSender.remind_volunteers_for(event)
      }.to change(ActionMailer::Base.deliveries, :count).by(pending_reminder_count)
    end

    it 'updates reminded_at' do
      expect {
        ReminderSender.remind_volunteers_for(event)
      }.to change { volunteer_rsvp.reload.reminded_at.present? }.to(true)
    end
  end
end

describe UpcomingEventsQuery do
  let(:events) { UpcomingEventsQuery.new }

  it 'includes events in the next three days' do
    event_tomorrow = create(:event, starts_at: Time.now + 1.day)
    found = false
    events.find_each { |event| found = true if event_tomorrow == event }
    found.should be_true
  end

  it 'doesnt include events in the far future' do
    event_four_days_away = create(:event, starts_at: Time.now + 4.days)
    events.find_each { |event| event.should_not eq(event_four_days_away) }
  end

  it 'doesnt include events in the past' do
    past_event = create(:event, starts_at: Time.now - 1.day)
    events.find_each { |event| event.should_not eq(past_event) }
  end
end