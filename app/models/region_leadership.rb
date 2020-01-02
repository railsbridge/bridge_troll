# frozen_string_literal: true

class RegionLeadership < ApplicationRecord
  belongs_to :region
  belongs_to :user, inverse_of: :region_leaderships

  validates :user, uniqueness: { scope: :region }
end
