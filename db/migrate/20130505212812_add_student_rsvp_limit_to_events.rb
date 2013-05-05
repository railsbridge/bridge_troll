class AddStudentRsvpLimitToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    def historical?
      meetup_volunteer_event_id || meetup_student_event_id
    end
  end

  def up
    add_column :events, :student_rsvp_limit, :integer
    Event.find_each do |event|
      unless event.historical?
        event.update_attribute(:student_rsvp_limit, 100)
      end
    end
  end

  def down
    remove_column :events, :student_rsvp_limit
  end
end
