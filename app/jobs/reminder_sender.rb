class ReminderSender
  def self.send_all_reminders
    UpcomingEventsQuery.new.find_each do |event|
      remind_volunteers_for(event)
    end
  end

  def self.remind_volunteers_for(event)
    event.volunteer_rsvps.where(:reminded_at => nil).find_each do |rsvp|
      RsvpMailer.reminder(rsvp).deliver
      rsvp.update_attributes(reminded_at: Time.now)
    end
  end
end

class UpcomingEventsQuery
  def initialize(relation = Event.scoped)
    @relation = relation
  end

  def find_each(&block)
    @relation
      .where("events.starts_at > ?", Time.zone.now)
      .where("events.starts_at < ?", Time.zone.now + 3.days)
      .find_each(&block)
  end
end