class Day < ActiveRecord::Base
  attr_accessible :date, :start_time, :end_time
  validates_presence_of :date, :start_time, :end_time
  belongs_to :event
end
