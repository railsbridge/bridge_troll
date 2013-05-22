class AddAllowStudentRsvpsFlagToEvent < ActiveRecord::Migration
  def change
    add_column :events, :allow_student_rsvp, :boolean, default: true
  end
end
