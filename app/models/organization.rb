class Organization < ActiveRecord::Base
  has_many :chapters, dependent: :destroy, inverse_of: :organization
  has_many :leaders, through: :organization_leaderships, source: :user
  has_many :organization_leaderships, dependent: :destroy

  def has_leader?(user)
    return false unless user

    return true if user.admin?

    user.organization_leaderships.map(&:organization_id).include?(id)
  end
end
