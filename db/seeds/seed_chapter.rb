module Seeder
  def self.seed_chapter
    org = Organization.find_or_create_by(name: 'RailsBridge')

    Chapter.find_or_create_by(name: 'RailsBridge Seattle', organization: org)
    Chapter.find_or_create_by(name: 'RailsBridge San Francisco', organization: org)
    Chapter.find_or_create_by(name: 'RailsBridge Tulsa', organization: org)
  end
end
