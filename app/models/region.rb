class Region < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:name]

  has_many :locations, dependent: :nullify
  has_many :events, through: :locations
  has_many :external_events
  has_and_belongs_to_many :users
  has_many :leaders, through: :region_leaderships, source: :user
  has_many :region_leaderships, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def has_leader?(user)
    return false unless user

    return true if user.admin?

    user.region_leaderships.map(&:region_id).include?(id)
  end

  def destroyable?
    (locations_count + external_events_count) == 0
  end

  def as_json(options = {})
    {
      name: name,
      users_subscribed_to_email_count: users.where(allow_event_email: true).count
    }
  end
end
