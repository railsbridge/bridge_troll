class Chapter < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:name, :organization_id]

  belongs_to :organization
  has_many :events
  has_many :external_events

  validates_presence_of :organization

  def destroyable?
    (events_count + external_events_count) == 0
  end
end
