# == Schema Information
# Schema version: 20120410060636
#
# Table name: locations
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  address    :text
#  created_at :datetime
#  updated_at :datetime
#

class Location < ActiveRecord::Base
  has_many :events
end
