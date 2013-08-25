class EventEmailRecipient < ActiveRecord::Base
  belongs_to :event_email
  belongs_to :recipient_rsvp, class_name: 'Rsvp'
end
