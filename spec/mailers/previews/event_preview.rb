class EventPreview < ActionMailer::Preview
  def from_organizer
    event = Event.first
    options = {
      event: event,
      sender: event.organizers.first,
      recipients: event.students,
      body: "Howdy folks, what's the haps?"
    }

    EventMailer.from_organizer(options)
  end

  def unpublished_event
    EventMailer.unpublished_event(Event.last)
  end

  def event_pending_approval
    EventMailer.event_pending_approval(Event.first)
  end

  def new_event
    EventMailer.new_event(Event.first)
  end

end
