# frozen_string_literal: true

class RegionsUser < ApplicationRecord
  belongs_to :user, inverse_of: :regions_users
  belongs_to :region, inverse_of: :regions_users
end
