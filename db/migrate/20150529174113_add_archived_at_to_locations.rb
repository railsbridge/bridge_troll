class AddArchivedAtToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :archived_at, :datetime
  end
end
