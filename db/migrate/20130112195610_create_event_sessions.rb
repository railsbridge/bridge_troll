class CreateEventSessions < ActiveRecord::Migration
  def change
    create_table :event_sessions do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :event_id
      t.timestamps
    end
  end
end
