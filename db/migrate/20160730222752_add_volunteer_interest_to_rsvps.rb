class AddVolunteerInterestToRsvps < ActiveRecord::Migration
  def change
  	add_column :rsvps, :volunteer_interest, :boolean, default: false, index: true
  end
end
