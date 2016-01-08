Dir[Rails.root.join('db', 'seeds', '*.rb')].each do |seed_file|
  require seed_file
end

if Rails.env.development?
  Seeder.seed_region
  Seeder.seed_chapter
  Seeder.admin_user
  Seeder.seed_event
end
