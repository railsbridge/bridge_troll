class AddUniquenessConstraintToChapters < ActiveRecord::Migration
  def change
    add_index :chapters_users, [:chapter_id, :user_id], unique: true
  end
end
