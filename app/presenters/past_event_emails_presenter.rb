# frozen_string_literal: true

class PastEventEmailsPresenter
  attr_reader :event

  def initialize(event)
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
        counts[email.id][:volunteers] += 1 if rsvp.role_volunteer?
        counts[email.id][:students] += 1 if rsvp.role_student?
      end
    end

    counts
  end
end
