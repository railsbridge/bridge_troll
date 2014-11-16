class AddChapterLeaderships < ActiveRecord::Migration
  def change
    create_table :chapter_leaderships do |t|
      t.integer :user_id
      t.integer :chapter_id

      t.references
    end
  end
end
