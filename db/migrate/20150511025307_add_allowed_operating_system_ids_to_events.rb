class AddAllowedOperatingSystemIdsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :restrict_operating_systems, :boolean, default: false
    add_column :events, :allowed_operating_system_ids, :string
  end
end
