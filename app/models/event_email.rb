# frozen_string_literal: true

class EventEmail < ApplicationRecord
  attr_accessor :attendee_group, :include_waitlisted, :only_checked_in, :cc_organizers

  belongs_to :event
  belongs_to :sender, class_name: 'User'

  has_many :event_email_recipients, dependent: :destroy
  has_many :recipient_rsvps, through: :event_email_recipients
  has_many :recipients, through: :recipient_rsvps, source: :user, source_type: 'User'

  validates :subject, :body, presence: true
end
