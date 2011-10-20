class CreateVolunteerings < ActiveRecord::Migration
  def self.up
    create_table :volunteerings do |t|
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :volunteerings
  end
end
