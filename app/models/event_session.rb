class EventSession < ActiveRecord::Base
  attr_accessible :starts_at, :ends_at
  validates_presence_of :starts_at, :ends_at
  belongs_to :event
end
