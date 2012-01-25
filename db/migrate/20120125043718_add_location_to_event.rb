class AddLocationToEvent < ActiveRecord::Migration
  def change
    add_column :events, :location_id, :integer
  end
end
