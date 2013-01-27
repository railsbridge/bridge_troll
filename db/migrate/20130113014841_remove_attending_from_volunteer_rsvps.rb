class RemoveAttendingFromVolunteerRsvps < ActiveRecord::Migration
  def up
    remove_column :volunteer_rsvps, :attending
  end

  def down
    add_column :volunteer_rsvps, :attending, :boolean
  end
end
