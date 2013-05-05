class AddWaitlistPositionToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :waitlist_position, :integer
  end
end
