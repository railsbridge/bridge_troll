# frozen_string_literal: true

class AddChapterLeadershipsAgain < ActiveRecord::Migration[4.2]
  def change
    create_table :chapter_leaderships do |t|
      t.integer :user_id
      t.integer :chapter_id

      t.references
    end

    add_foreign_key :chapter_leaderships, :users
    add_foreign_key :chapter_leaderships, :chapters
  end
end
