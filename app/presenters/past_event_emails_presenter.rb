class PastEventEmailsPresenter
  attr_reader :event

  def initialize event
    @event = event
  end

  def emails
    event.event_emails.order(:created_at)
  end

  def recipient_counts
    counts = {}

    emails.each do |email|
      counts[email.id] = {
        total: email.recipient_rsvps.length,
        volunteers: 0,
        students: 0
      }

      email.recipient_rsvps.each do |rsvp|
        if rsvp.role_volunteer?
          counts[email.id][:volunteers] += 1
        end
        if rsvp.role_student?
          counts[email.id][:students] += 1
        end
      end
    end

    counts
  end
end
