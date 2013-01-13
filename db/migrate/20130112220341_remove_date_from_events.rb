class RemoveDateFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :date
  end

  def down
    add_column :events, :date, :datetime
  end
end
