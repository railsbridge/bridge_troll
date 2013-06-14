class AddCheckinerToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :checkiner, :boolean, default: false
  end
end
