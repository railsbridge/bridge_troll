class AddRequiredForStudentsToEventSessions < ActiveRecord::Migration
  def change
    add_column :event_sessions, :required_for_students, :boolean, default: true
  end
end
