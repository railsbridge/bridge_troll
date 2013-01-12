class ChangeDateFieldsOnEventSessions < ActiveRecord::Migration
  def up
    remove_column :event_sessions, :date
    rename_column :event_sessions, :start_time, :starts_at
    rename_column :event_sessions, :end_time, :ends_at
  end

  def down
    add_column :event_sessions, :date, :datetime
    rename_column :event_sessions, :starts_at, :start_time
    rename_column :event_sessions, :ends_at, :end_time
  end
end
