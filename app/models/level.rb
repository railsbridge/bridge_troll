class Level < ActiveRecord::Base
  belongs_to :course
  validates :num, presence: true, numericality: true, uniqueness: { scope: :course_id }
  validates :color, presence: true, uniqueness: { scope: :course_id }
  validates :title, presence: true
  validates :level_description, presence: true

  # level_description is an array that is getting saved as a string
  # this parses it back as an array
  def description
    if level_description.blank?
      []
    else
      begin
        ActiveSupport::JSON.decode(level_description)
      rescue
        level_description.gsub(", ", ",").gsub(/[\[\]]/, "").split(",")
      end
    end
  end
end
