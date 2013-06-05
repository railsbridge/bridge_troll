class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.references :event
      t.string :name

      t.timestamps
    end
    add_index :sections, :event_id
  end
end
