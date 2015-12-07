class SeedChaptersFromRegions < ActiveRecord::Migration
  class Chapter < ActiveRecord::Base
    belongs_to :organization
    has_many :events
    has_many :external_events
  end

  class Location < ActiveRecord::Base
    has_many :events
  end

  class Region < ActiveRecord::Base
    has_many :locations
    has_many :events, through: :locations
    has_many :external_events
  end

  class Event < ActiveRecord::Base
    belongs_to :region
    belongs_to :chapter
  end

  class ExternalEvent < ActiveRecord::Base
    belongs_to :region
    belongs_to :chapter
  end

  def up
    add_column :events, :chapter_id, :integer
    add_column :external_events, :chapter_id, :integer

    rb_org = Organization.find_by(name: 'RailsBridge')

    Region.find_each do |region|
      chapter_name = region.name
      chapter_name = "RailsBridge #{chapter_name}" unless chapter_name.match('RailsBridge')
      chapter = Chapter.create(name: chapter_name, organization: rb_org)
      region.events.update_all(chapter_id: chapter.id)
    end

    sf_chapter = Chapter.find_by(name: 'RailsBridge San Francisco')
    if sf_chapter
      Event.where('chapter_id IS NULL').update_all(chapter_id: sf_chapter.id)
    end

    ExternalEvent.find_each do |external_event|
      if external_event.region
        chapter_name = external_event.region.name
        chapter_name = "RailsBridge #{chapter_name}" unless chapter_name.match('RailsBridge')
        chapter = Chapter.find_or_create_by(name: chapter_name, organization: rb_org)
        external_event.update_attributes(chapter_id: chapter.id)
      else
      end
    end

    change_column_null :events, :chapter_id, false
    add_index :events, :chapter_id
    add_foreign_key :events, :chapters

    add_index :external_events, :chapter_id
    add_foreign_key :external_events, :chapters
  end

  def down
    remove_column :events, :chapter_id
  end
end
