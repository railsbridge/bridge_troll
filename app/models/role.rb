class Role < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true
end
