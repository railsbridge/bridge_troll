class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
