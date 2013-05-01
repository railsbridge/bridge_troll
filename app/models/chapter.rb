class Chapter < ActiveRecord::Base
  attr_accessible :name

  has_many :locations
  has_many :events, -> { where published: true }, through: :locations
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_uniqueness_of :name
end
