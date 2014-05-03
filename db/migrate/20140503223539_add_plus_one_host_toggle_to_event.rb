class AddPlusOneHostToggleToEvent < ActiveRecord::Migration
  def change
    add_column :events, :plus_one_host_toggle, :boolean, default: true
  end
end
