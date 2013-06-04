class SetVolunteerClassLevelToZero < ActiveRecord::Migration
  Role::VOLUNTEER = OpenStruct.new(id: 2)

  class Rsvp < ActiveRecord::Base; end

  def up
    Rsvp.where(role_id: Role::VOLUNTEER.id).find_each do |rsvp|
      rsvp.class_level = 0
      rsvp.save!
    end
  end

  def down
    Rsvp.where(role_id: Role::VOLUNTEER.id).find_each do |rsvp|
      rsvp.class_level = nil
      rsvp.save!
    end
  end
end
