class AddVolunteerRsvpLimitToEvents < ActiveRecord::Migration
  def change
    add_column :events, :volunteer_rsvp_limit, :integer, default: 1
  end
end
