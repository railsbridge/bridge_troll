class Course < ActiveRecord::Base
  has_many :levels, dependent: :destroy
  has_many :events
  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :description

  accepts_nested_attributes_for :levels, allow_destroy: true
end
