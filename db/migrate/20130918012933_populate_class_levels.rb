class PopulateClassLevels < ActiveRecord::Migration
  class Rsvp < ActiveRecord::Base; end
  class Section < ActiveRecord::Base
    has_many :rsvps
  end

  def up
    Section.find_each do |section|
      level = section.rsvps.where(role_id: Role::STUDENT.id).first.class_level || 0
      section.update_attribute(:class_level, level)
    end
  end

  def down
  end
end
