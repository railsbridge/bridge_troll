class ChapterLeadership < ActiveRecord::Base
  belongs_to :chapter
  belongs_to :user

  validates :user, uniqueness: { scope: :chapter }
end
