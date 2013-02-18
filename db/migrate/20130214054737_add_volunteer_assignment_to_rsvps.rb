class AddVolunteerAssignmentToRsvps < ActiveRecord::Migration
  class VolunteerAssignment < ActiveHash::Base
    UNASSIGNED = 1
  end

  def change
    add_column :rsvps, :volunteer_assignment_id, :integer, default: VolunteerAssignment::UNASSIGNED, null: false
  end
end
