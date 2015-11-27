module Seeder
  def self.seed_region
    # seeds the database with an admin user
    region = Region.where(name: 'RailsBridge Seattle').first_or_initialize
    region.save!
    region = Region.where(name: 'RailsBridge San Francisco').first_or_initialize
    region.save!
    region = Region.where(name: 'RailsBridge Tulsa').first_or_initialize
    region.save!
  end
end
