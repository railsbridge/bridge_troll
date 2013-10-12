class AddChapterIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :chapter_id, :integer
  end
end
