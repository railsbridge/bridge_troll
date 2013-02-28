class AddMeetupStudentEventIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :meetup_student_event_id, :integer
  end
end
