class EventSession < ActiveRecord::Base
  attr_accessible :starts_at, :ends_at
  validates_presence_of :starts_at, :ends_at
  belongs_to :event

  def date_in_time_zone start_or_end
    send(start_or_end).in_time_zone(ActiveSupport::TimeZone.new(event.time_zone))
  end
end
