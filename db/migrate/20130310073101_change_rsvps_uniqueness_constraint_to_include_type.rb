class ChangeRsvpsUniquenessConstraintToIncludeType < ActiveRecord::Migration
  def up
    remove_index :rsvps, name: "index_volunteer_rsvps_on_user_id_and_event_id"
    add_index :rsvps, [:user_id, :event_id, :user_type], name: "index_rsvps_on_user_id_and_event_id_and_event_type", unique: true
  end

  def down
    remove_index :rsvps, name: "index_rsvps_on_user_id_and_event_id_and_event_type"
    add_index :rsvps, ["user_id", "event_id"], name: "index_volunteer_rsvps_on_user_id_and_event_id", :unique => true
  end
end
