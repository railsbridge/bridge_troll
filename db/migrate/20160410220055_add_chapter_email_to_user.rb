class AddChapterEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :allow_chapter_email, :boolean, default: true
  end
end
