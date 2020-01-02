# frozen_string_literal: true

require_relative 'course_populator'

module Seeder
  def self.seed_courses
    CoursePopulator.populate_courses
  end
end
