class RenameVolunteerRsvpsToRsvps < ActiveRecord::Migration
  def change
    rename_table :volunteer_rsvps, :rsvps
  end
end
