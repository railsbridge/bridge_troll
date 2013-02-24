class AddMeetupVolunteerEventIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :meetup_volunteer_event_id, :integer
  end
end
