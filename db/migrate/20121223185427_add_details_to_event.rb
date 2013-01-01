class AddDetailsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :details, :text
  end
end
