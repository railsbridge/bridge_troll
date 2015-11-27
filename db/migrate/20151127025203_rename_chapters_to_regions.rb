class RenameChaptersToRegions < ActiveRecord::Migration
  def change
    rename_table :chapters, :regions
    rename_table :chapters_users, :regions_users
    rename_table :chapter_leaderships, :region_leaderships
    rename_column :region_leaderships, :chapter_id, :region_id
    rename_column :regions_users, :chapter_id, :region_id
    rename_column :locations, :chapter_id, :region_id
    rename_column :external_events, :chapter_id, :region_id
  end
end
