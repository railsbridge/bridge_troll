class DeleteExistingEventsAndVolunteerRsvps < ActiveRecord::Migration
  def up
    puts "Deleting all your existing events and their associated models in the name of PROGRESS!"
    execute("DELETE FROM volunteer_rsvps")
    execute("DELETE FROM event_organizers")
    execute("DELETE FROM events")
  end
end
