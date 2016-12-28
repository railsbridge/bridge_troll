class Level < ActiveRecord::Base
  belongs_to :course
  validates :num, presence: true, numericality: true, uniqueness: { scope: :course_id }
  validates :color, presence: true, uniqueness: { scope: :course_id }
  validates :title, presence: true
  validates :level_description, presence: true
  serialize :level_description, Array
  alias_attribute :description, :level_description
end
