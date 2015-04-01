class AddVolunteerWaitlistRsvpsCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :volunteer_waitlist_rsvps_count, :integer, default: 0
  end
end
