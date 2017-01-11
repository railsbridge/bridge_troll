class Level < ActiveRecord::Base
  belongs_to :course
  validates :num, presence: true, numericality: true, uniqueness: { scope: :course_id }
  validates :color, presence: true, uniqueness: { scope: :course_id }
  validates :title, presence: true
  validates :level_description, presence: true
  serialize :level_description, Array
  alias_attribute :description, :level_description

  def level_description_bullets
    level_description.map { |line| "* #{line}" }.join("\n")
  end

  def level_description_bullets=(value)
    self.level_description = value.split("\n").map { |line| line.gsub(/^\s*\*\s*/, '').strip }
  end
end
