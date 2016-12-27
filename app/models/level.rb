class Level < ActiveRecord::Base
  belongs_to :course
  validates :num, presence: true, numericality: true
  validates :color, presence: true
  validates :title, presence: true
  validates :level_description, presence: true
  validate :description_must_be_array

  def description
    if level_description.blank?
      []
    else
      ActiveSupport::JSON.decode(level_description)
    end
  end

  def description_must_be_array
    begin
      ActiveSupport::JSON.decode(level_description)
    rescue
      errors.add(:description, "must be an array.")
    end
  end
end
