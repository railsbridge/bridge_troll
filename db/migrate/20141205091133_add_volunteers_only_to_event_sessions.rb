class AddVolunteersOnlyToEventSessions < ActiveRecord::Migration
  def change
    add_column :event_sessions, :volunteers_only, :boolean, default: false
  end
end
