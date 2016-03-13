class OrganizationLeadership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  validates :user, uniqueness: { scope: :organization }
end
