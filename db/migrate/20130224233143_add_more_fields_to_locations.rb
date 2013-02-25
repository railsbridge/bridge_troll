class AddMoreFieldsToLocations < ActiveRecord::Migration
  class Location < ActiveRecord::Base; end

  NEW_COLUMNS = [:address_2, :city, :state, :zip]
  def up
    change_column :locations, :address, :string
    rename_column :locations, :address, :address_1
    NEW_COLUMNS.each do |col|
      add_column :locations, col, :string
    end
    Location.find_each do |loc|
      loc.city = 'San Francisco'
      loc.save!
    end
  end

  def down
    rename_column :locations, :address_1, :address
    change_column :locations, :address, :text
    NEW_COLUMNS.each do |col|
      remove_column :locations, col
    end
  end
end
