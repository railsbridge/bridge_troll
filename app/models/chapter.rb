class Chapter < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:name, :organization_id]

  belongs_to :organization, inverse_of: :chapters
  has_many :events
  has_many :external_events
  has_many :leaders, through: :chapter_leaderships, source: :user
  has_many :chapter_leaderships, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :organization

  def has_leader?(user)
    return false unless user

    return true if user.admin?

    user.chapter_leaderships.map(&:chapter_id).include?(id)
  end

  def destroyable?
    (events_count + external_events_count) == 0
  end

  def code_of_conduct_url
    organization.code_of_conduct_url || Event::DEFAULT_CODE_OF_CONDUCT_URL
  end
end
