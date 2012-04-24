class AddIndexToVolunteerRsvp < ActiveRecord::Migration
  def change
    add_index :volunteer_rsvps, [:user_id, :event_id], :name => "index_volunteer_rsvps_on_user_id_and_event_id", :unique => true
  end
end
