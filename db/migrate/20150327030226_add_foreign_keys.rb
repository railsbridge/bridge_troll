class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :authentications, :users
    add_foreign_key :chapter_leaderships, :users
    add_foreign_key :chapter_leaderships, :chapters
    add_foreign_key :chapters_users, :chapters
    add_foreign_key :chapters_users, :users
    add_foreign_key :dietary_restrictions, :rsvps
    add_foreign_key :event_email_recipients, :event_emails
    add_foreign_key :event_email_recipients, :rsvps, column: :recipient_rsvp_id
    add_foreign_key :event_emails, :events
    add_foreign_key :event_emails, :users, column: :sender_id
    add_foreign_key :event_sessions, :events
    add_foreign_key :events, :locations
    add_foreign_key :locations, :chapters
    add_foreign_key :profiles, :users
    add_foreign_key :rsvp_sessions, :rsvps
    add_foreign_key :rsvp_sessions, :event_sessions
    add_foreign_key :rsvps, :events
    add_foreign_key :rsvps, :sections
    add_foreign_key :sections, :events
    add_foreign_key :surveys, :rsvps
  end
end
