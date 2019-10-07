class AddLocationToEventSessions < ActiveRecord::Migration[4.2]
  def change
    add_reference :event_sessions, :location, index: true, foreign_key: true
  end
end
