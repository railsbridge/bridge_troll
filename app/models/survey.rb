# frozen_string_literal: true

class Survey < ApplicationRecord
  belongs_to :rsvp

  validates :rsvp_id, uniqueness: { message: 'Only one survey response allowed per user.' }
  validates :recommendation_likelihood, allow_blank: true,
                                        numericality: { only_integer: true, greater_than: 0, less_than: 11 }
end
