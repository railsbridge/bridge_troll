class AddOpenToEvents < ActiveRecord::Migration
  def change
    add_column :events, :open, :boolean, default: true
  end
end