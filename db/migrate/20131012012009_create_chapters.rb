class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name
      t.integer :locations_count, default: 0

      t.timestamps
    end
  end
end
