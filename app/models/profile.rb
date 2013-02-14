class Profile < ActiveRecord::Base
  attr_accessible :childcaring, :designing, :outreach, :linux, :macosx, :mentoring,
                  :other, :user_id, :windows, :writing, :bio

  belongs_to :user

  validates_presence_of :user_id
  validates_uniqueness_of :user_id
end