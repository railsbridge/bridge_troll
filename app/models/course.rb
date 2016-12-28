class Course < ActiveRecord::Base
  has_many :levels, dependent: :destroy
  has_many :events
  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :description
end
