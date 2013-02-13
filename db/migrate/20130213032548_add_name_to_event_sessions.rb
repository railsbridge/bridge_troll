class AddNameToEventSessions < ActiveRecord::Migration
  class EventSession < ActiveRecord::Base; end

  def up
    add_column :event_sessions, :name, :string
    EventSession.find_each do |session|
      session.name = "Session With ID of #{session.id}"
      session.save!
    end
    # gotta do a little dance for SQLite to hate the null constraint less
    change_column :event_sessions, :name, :string, null: false

    add_index :event_sessions, [:event_id, :name], :unique => true
  end

  def down
    remove_index :event_sessions, column: [:event_id, :name]

    remove_column :event_sessions, :name
  end
end
