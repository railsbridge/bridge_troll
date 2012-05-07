class Role < ActiveRecord::Base
  validates :title, :presence => true, :uniqueness => true
end
# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

