# frozen_string_literal: true

class EventEmailRecipient < ApplicationRecord
  belongs_to :event_email
  belongs_to :recipient_rsvp, class_name: 'Rsvp', inverse_of: :event_email_recipients
end
