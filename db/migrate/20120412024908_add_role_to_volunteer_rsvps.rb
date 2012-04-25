class AddRoleToVolunteerRsvps < ActiveRecord::Migration
  def change
    add_column :volunteer_rsvps, :role_id, :integer
  end
end
