class RegionLeadership < ActiveRecord::Base
  belongs_to :region
  belongs_to :user

  validates :user, uniqueness: { scope: :region }
end
