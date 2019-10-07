class Survey < ActiveRecord::Base
  belongs_to :rsvp

  validates_uniqueness_of :rsvp_id, message: "Only one survey response allowed per user."
  validates :recommendation_likelihood, allow_blank: true, numericality: { only_integer: true, greater_than: 0, less_than: 11 }
end
