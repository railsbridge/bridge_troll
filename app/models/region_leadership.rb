class RegionLeadership < ActiveRecord::Base
  belongs_to :region
  belongs_to :user, inverse_of: :region_leaderships

  validates :user, uniqueness: { scope: :region }
end
