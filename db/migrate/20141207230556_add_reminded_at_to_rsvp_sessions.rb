class AddRemindedAtToRsvpSessions < ActiveRecord::Migration
  def change
    add_column :rsvp_sessions, :reminded_at, :datetime
  end
end
