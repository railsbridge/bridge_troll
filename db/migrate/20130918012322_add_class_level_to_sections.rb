class AddClassLevelToSections < ActiveRecord::Migration
  def change
    add_column :sections, :class_level, :integer
  end
end
