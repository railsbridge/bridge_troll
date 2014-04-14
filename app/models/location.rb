class Location < ActiveRecord::Base
  has_many :events
  belongs_to :chapter, counter_cache: true

  attr_accessible :name, :address_1, :address_2, :city, :state, :zip, :chapter_id

  validates_presence_of :name, :address_1, :city, :chapter
  unless Rails.env.test?
    geocoded_by :full_address
    after_validation :geocode
  end

  def full_address
    "#{self.address_1}, #{self.city}, #{self.state}, #{self.zip}"
  end

  def name_with_chapter
    "#{name} (#{chapter.name})"
  end

  def editable_by?(user)
    return true if events_count == 0
    return true if user.admin?

    published_events = events.where(published: true)
    notable_events = if published_events.present?
      published_events
    else
      events.where(published: false)
    end

    notable_events.map { |e| e.organizers }.flatten.map(&:id).include?(user.id)
  end

  def as_json(options = {})
    {
      name: name,
      address_1: address_1,
      address_2: address_2,
      city: city,
      state: state,
      zip: zip,
      latitude: latitude,
      longitude: longitude,
    }
  end
end