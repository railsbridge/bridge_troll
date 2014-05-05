class AddPlusOneHostToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :plus_one_host, :text
  end
end
