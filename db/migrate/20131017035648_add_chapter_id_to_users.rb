class AddChapterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :chapter_id, :integer
  end
end
