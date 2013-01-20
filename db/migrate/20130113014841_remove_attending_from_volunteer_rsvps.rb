class RemoveAttendingFromVolunteerRsvps < ActiveRecord::Migration
  def up
    remove_column :rsvps, :attending
  end

  def down
    add_column :rsvps, :attending, :boolean
  end
end
