class AddChapterIdToExternalEvents < ActiveRecord::Migration
  def change
    add_reference :external_events, :chapter, index: true
    add_foreign_key :external_events, :chapters
  end
end
