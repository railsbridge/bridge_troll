# frozen_string_literal: true

class ChapterLeadership < ApplicationRecord
  belongs_to :chapter
  belongs_to :user, inverse_of: :chapter_leaderships

  validates :user, uniqueness: { scope: :chapter }
end
