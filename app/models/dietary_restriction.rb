class DietaryRestriction < ActiveRecord::Base
  belongs_to :rsvp

  DIETS = %w{ vegetarian vegan gluten-free dairy-free }

  validates_uniqueness_of :restriction, {scope: :rsvp_id}

  validates_inclusion_of :restriction, in: DIETS
end