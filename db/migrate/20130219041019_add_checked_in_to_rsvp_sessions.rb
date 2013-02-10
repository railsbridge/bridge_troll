class AddCheckedInToRsvpSessions < ActiveRecord::Migration
  def change
    add_column :rsvp_sessions, :checked_in, :boolean, default: false
  end
end
