class AddDietaryInfoToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :dietary_info, :string
  end
end
