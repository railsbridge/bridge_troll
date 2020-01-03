# frozen_string_literal: true

Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |seed_file|
  require seed_file
end

if Rails.env.development?
  Seeder.seed_region
  Seeder.seed_chapter
  Seeder.admin_user
  Seeder.seed_courses
  Seeder.seed_event
  Seeder.seed_multiple_location_event
  Seeder.seed_past_event
end
