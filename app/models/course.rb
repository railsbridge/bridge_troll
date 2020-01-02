# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :levels, dependent: :destroy
  has_many :events, dependent: :nullify
  validates :name, presence: true
  validates :title, presence: true
  validates :description, presence: true

  accepts_nested_attributes_for :levels, allow_destroy: true
  validates :levels, length: { maximum: 5 }
  validate :unique_level_positions
  validate :unique_level_colors

  def unique_level_positions
    unique_level_values(:num, 'position must be unique')
  end

  def unique_level_colors
    unique_level_values(:color, 'color must be unique')
  end

  private

  def unique_level_values(field, message)
    unless levels.map(&field).length == levels.map(&field).uniq.length
      errors.add(:level, message)
    end
  end
end
