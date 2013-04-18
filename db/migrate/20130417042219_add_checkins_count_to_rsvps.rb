class AddCheckinsCountToRsvps < ActiveRecord::Migration
  def up
    add_column :rsvps, :checkins_count, :integer, default: 0

    Rsvp.reset_column_information
    Rsvp.find_each do |rsvp|
      rsvp.update_attribute :checkins_count, rsvp.rsvp_sessions.where("rsvp_sessions.checked_in = ?", true).count
    end
  end

  def down
    remove_column :rsvps, :checkins_count
  end
end
