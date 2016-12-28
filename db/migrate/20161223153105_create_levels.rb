class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.references :course, foreign_key: true
      t.integer :num
      t.string :color
      t.string :title
      t.text :level_description

      t.timestamps null: false
    end
  end
end
