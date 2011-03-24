class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
      t.integer :event_id, :null => false
      t.boolean :waitlisted, :default => false
      t.datetime :withdrawn_at
      t.string :registrant_name, :null => false
      t.string :registrant_email, :null => false
      t.string :registrant_description
      t.integer :inviter_id
      t.integer :class_level, :default => 0

      t.timestamps
    end
    add_index :registrations, :event_id
  end

  def self.down
    drop_table :registrations
  end
end
