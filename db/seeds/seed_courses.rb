require_relative 'course_populator'

module Seeder
  def self.seed_courses
    CoursePopulator.new.populate_courses
  end
end
