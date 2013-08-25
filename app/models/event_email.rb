class EventEmail < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'

  has_many :event_email_recipients, dependent: :destroy

  has_many :recipient_rsvps, through: :event_email_recipients
  has_many :recipients, through: :recipient_rsvps, source: :user, source_type: 'User'
end
