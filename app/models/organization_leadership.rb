# frozen_string_literal: true

class OrganizationLeadership < ApplicationRecord
  belongs_to :organization
  belongs_to :user, inverse_of: :organization_leaderships

  validates :user, uniqueness: { scope: :organization }
end
