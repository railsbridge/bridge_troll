# frozen_string_literal: true

class DietaryRestriction < ApplicationRecord
  belongs_to :rsvp

  DIETS = %w[vegetarian vegan gluten-free dairy-free].freeze

  validates :restriction, uniqueness: { scope: :rsvp_id }

  validates :restriction, inclusion: { in: DIETS }
end
