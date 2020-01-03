# frozen_string_literal: true

require Rails.root.join('db/seeds/course_populator')

desc 'Populate courses (only run once)'
task populate_courses: :environment do |_t, _args|
  CoursePopulator.populate_courses
end
