class CreateRsvpSessionsTable < ActiveRecord::Migration
  def change
    create_table :rsvp_sessions do |t|
      t.references :rsvp
      t.references :event_session

      t.timestamps
    end
  end
end
