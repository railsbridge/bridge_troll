class SetVolunteerClassLevelToZero < ActiveRecord::Migration
  class Rsvp < ActiveRecord::Base; end

  def up
	Rsvp.where(role_id: Role::VOLUNTEER.id).find_each do |rsvp|
	    rsvp.class_level = 0
	    rsvp.save!
	end
  end

  def down
  	volunteerRsvps = Rsvp.find_all_by_role_id(Role::VOLUNTEER)
  	volunteerRsvps.each do |rsvp|
		rsvp.class_level = nil
		rsvp.save!
  	end
  end
end
