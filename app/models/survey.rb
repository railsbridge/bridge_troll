class Survey < ActiveRecord::Base
  attr_accessible :good_things, :bad_things, :other_comments, :rsvp_id, :recommendation_likelihood

  belongs_to :rsvp

  validates_presence_of :rsvp_id
  validates_uniqueness_of :rsvp_id, message: "Only one survey response allowed per user."
  validates :recommendation_likelihood, allow_blank: true, numericality: { only_integer: true, greater_than: 0, less_than: 11 }
end
