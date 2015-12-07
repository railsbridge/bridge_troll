class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name
      t.integer :events_count
      t.integer :external_events_count
      t.references :organization, null: false

      t.timestamps null: false
    end
    add_foreign_key :chapters, :organizations
  end
end
