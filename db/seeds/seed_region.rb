module Seeder
  def self.seed_region
    Region.find_or_create_by(name: 'Seattle')
    Region.find_or_create_by(name: 'San Francisco')
    Region.find_or_create_by(name: 'Tulsa')
  end
end
