# frozen_string_literal: true

class ExternalEvent < ApplicationRecord
  belongs_to :region, counter_cache: true, optional: true
  belongs_to :chapter, counter_cache: true, optional: true
  has_one :organization, through: :chapter

  validates :name, :starts_at, :city, presence: true

  def self.past
    where('ends_at < ?', Time.now.utc)
  end

  def self.upcoming
    where('ends_at >= ?', Time.now.utc)
  end

  def title
    name
  end

  def imported_event_data
    false
  end

  def location_name
    location
  end

  def location_city_and_state
    city
  end

  def date_in_time_zone(start_or_end)
    send(start_or_end.to_sym)
  end

  def as_json(_options = {})
    fake_sessions = [{ starts_at: starts_at }]
    fake_sessions << { starts_at: ends_at } if ends_at && starts_at.to_date != ends_at.to_date

    {
      url: url,
      title: name,
      location: {
        name: location,
        city: city
      },
      organizers: organizers,
      sessions: fake_sessions,
      organization: organization.try(:name),
      workshop: true
    }
  end

  def to_linkable
    url.presence
  end
end
