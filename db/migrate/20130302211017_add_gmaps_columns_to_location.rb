class AddGmapsColumnsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :latitude,  :float 
    add_column :locations, :longitude, :float
    add_column :locations, :gmaps, :boolean
  end
end