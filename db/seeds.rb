require Rails.root.join('db', 'seeds', 'seed_region')
require Rails.root.join('db', 'seeds', 'admin_user')
require Rails.root.join('db', 'seeds', 'seed_event')

if Rails.env.development?
  Seeder::seed_region
  Seeder::admin_user
  Seeder::seed_event
end
