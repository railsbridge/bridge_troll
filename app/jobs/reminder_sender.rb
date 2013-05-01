class ReminderSender
  def self.send_all_reminders
    UpcomingEventsQuery.new.find_each do |event|
      remind_attendees_for(event)
    end
  end

  def self.remind_attendees_for(event)
    due_reminders = event.rsvps.confirmed.where(:reminded_at => nil)
    puts "Sending #{due_reminders.count} reminders for #{event.title}..." unless Rails.env.test?
    due_reminders.find_each do |rsvp|
      RsvpMailer.reminder(rsvp).deliver
      rsvp.reminded_at = Time.now
      rsvp.save!
    end
  end
end

class UpcomingEventsQuery
  def initialize(relation = Event.all)
    @relation = relation
  end

  def find_each(&block)
    @relation
      .where("events.starts_at > ?", Time.zone.now)
      .where("events.starts_at < ?", Time.zone.now + 3.days)
      .find_each(&block)
  end
end