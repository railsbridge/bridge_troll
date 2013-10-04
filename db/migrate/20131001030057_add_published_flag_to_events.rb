class AddPublishedFlagToEvents < ActiveRecord::Migration
  def up
    add_column :events, :published, :boolean
    execute("UPDATE events SET published = ?", true)
  end

  def down
    remove_column :events, :published
  end
end
