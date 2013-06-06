class Section < ActiveRecord::Base
  belongs_to :event
  has_many :rsvps, dependent: :nullify
  attr_accessible :name
end
