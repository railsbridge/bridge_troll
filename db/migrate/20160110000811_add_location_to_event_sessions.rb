class AddLocationToEventSessions < ActiveRecord::Migration
  def change
    add_reference :event_sessions, :location, index: true, foreign_key: true
  end
end
