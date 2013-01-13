class RenameDaysToEventSessions < ActiveRecord::Migration
  def self.up
      rename_table :days, :event_sessions
    end 

    def self.down
      rename_table :event_sessions, :days
    end
end
