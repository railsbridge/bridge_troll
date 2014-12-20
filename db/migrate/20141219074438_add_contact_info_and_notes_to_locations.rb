class AddContactInfoAndNotesToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :contact_info, :text
    add_column :locations, :notes, :text
  end
end
