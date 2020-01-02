# frozen_string_literal: true

class Chapter < ApplicationRecord
  belongs_to :organization, inverse_of: :chapters
  has_many :events, dependent: :nullify
  has_many :external_events, dependent: :nullify
  has_many :chapter_leaderships, dependent: :destroy
  has_many :leaders, through: :chapter_leaderships, source: :user

  validates :name, presence: true
  validates :name, uniqueness: true

  def leader?(user)
    return false unless user

    user.admin? || user.chapter_leaderships.map(&:chapter_id).include?(id)
  end

  def destroyable?
    (events_count + external_events_count) == 0
  end

  def code_of_conduct_url
    organization.code_of_conduct_url || Event::DEFAULT_CODE_OF_CONDUCT_URL
  end
end
