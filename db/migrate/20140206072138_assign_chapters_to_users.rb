class AssignChaptersToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_and_belongs_to_many :chapters
  end

  class Rsvp < ActiveRecord::Base
    belongs_to :user, polymorphic: true
  end

  class Event < ActiveRecord::Base
    belongs_to :location
    has_many :rsvps, dependent: :destroy
  end

  class Location < ActiveRecord::Base
    belongs_to :chapter
  end

  class Chapter < ActiveRecord::Base
    has_many :locations
    has_many :events, through: :locations
  end

  def up
    Event.includes(rsvps: :user).includes(location: :chapter).find_each do |event|
      event.rsvps.where(user_type: 'User').each do |rsvp|
        exists = rsvp.user.chapters.reload.map(&:id).include?(event.location.chapter.id)
        execute("INSERT INTO chapters_users (user_id, chapter_id) VALUES (#{rsvp.user.id}, #{event.location.chapter.id})") unless exists
      end
    end
  end

  def down
  end
end
