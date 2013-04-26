class AddRemindedAtToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :reminded_at, :datetime
  end
end
