class Chapter < ActiveRecord::Base
  belongs_to :organization
  has_many :events, counter_cache: true
  has_many :external_events, counter_cache: true

  validates_presence_of :organization
end
