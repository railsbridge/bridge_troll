module Seeder
  def self.seed_chapter
    # seeds the database with an admin user
    chapter = Chapter.where(name: 'RailsBridge Seattle').first_or_initialize
    chapter.save!
    chapter = Chapter.where(name: 'RailsBridge San Francisco').first_or_initialize
    chapter.save!
    chapter = Chapter.where(name: 'RailsBridge Tulsa').first_or_initialize
    chapter.save!
  end
end
