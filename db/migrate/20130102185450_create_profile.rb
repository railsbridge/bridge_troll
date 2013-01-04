class CreateProfile < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.boolean :teaching
      t.boolean :taing
      t.boolean :coordinating
      t.boolean :childcaring
      t.boolean :writing
      t.boolean :hacking
      t.boolean :designing
      t.boolean :evangelizing
      t.boolean :mentoring
      t.boolean :macosx
      t.boolean :windows
      t.boolean :linux
      t.text :other

      t.timestamps
    end
  end
end
