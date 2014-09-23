class ExternalEvent < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:city, :ends_at, :location, :name, :organizers, :starts_at, :url]

  validates_presence_of :name, :starts_at, :location

  def self.past
    where('ends_at < ?', Time.now.utc)
  end

  def title
    name
  end

  def meetup_student_event_id
    nil
  end

  def meetup_volunteer_event_id
    nil
  end

  def location_name
    location
  end

  def location_city_and_state
    city
  end

  def date_in_time_zone start_or_end
    send(start_or_end.to_sym)
  end

  def as_json(options = {})
    fake_sessions =  [{ starts_at: starts_at }]
    fake_sessions << { starts_at: ends_at } if ends_at && starts_at.to_date != ends_at.to_date

    {
      url: url,
      title: name,
      location: {
        name: location,
        city: city
      },
      organizers: organizers,
      sessions: fake_sessions
    }
  end
end
