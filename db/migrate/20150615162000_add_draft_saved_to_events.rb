class AddDraftSavedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :draft_saved, :boolean
  end
end
