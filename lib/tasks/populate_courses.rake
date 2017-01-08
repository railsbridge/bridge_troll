require Rails.root.join('db', 'seeds', 'course_populator')

desc "Populate courses (only run once)"
task :populate_courses => :environment do |t, args|
  CoursePopulator.new.populate_courses
end