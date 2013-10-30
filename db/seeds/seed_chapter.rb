module Seeder
  def self.seed_chapter
    # seeds the database with an admin user
    chapter = Chapter.where(name: 'Seattle').first_or_initialize
    chapter.save!
    chapter = Chapter.where(name: 'San Francisco').first_or_initialize
    chapter.save!
    chapter = Chapter.where(name: 'Tulsa').first_or_initialize
    chapter.save!
  end
end
