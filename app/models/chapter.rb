class Chapter < ActiveRecord::Base
  belongs_to :organization
  has_many :events
  has_many :external_events

  validates_presence_of :organization
end
