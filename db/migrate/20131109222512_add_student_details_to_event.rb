class AddStudentDetailsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :student_details, :text
  end
end
