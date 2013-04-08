class AddStudentFieldsToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :operating_system_id, :integer
    add_column :rsvps, :job_details, :text
    add_column :rsvps, :class_level, :integer
  end
end
