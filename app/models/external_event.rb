class ExternalEvent < ActiveRecord::Base
  attr_accessible :city, :ends_at, :location, :name, :organizers, :starts_at, :url
  validates_presence_of :name, :starts_at, :location

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
end
