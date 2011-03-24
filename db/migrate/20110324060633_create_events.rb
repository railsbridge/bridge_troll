class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name, :null => false
      t.integer :location_id, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false
      t.text :description
      t.integer :capacity, :null => false, :default => 1
      t.integer :guests_per_user, :null => false, :default => 0

      t.timestamps
    end
    add_index :events, :location_id
  end

  def self.down
    drop_table :events
  end
end
