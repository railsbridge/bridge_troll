class Profile < ActiveRecord::Base
  attr_accessible :childcaring, :coordinating, :designing, :evangelizing, :hacking, :linux, :macosx, :mentoring,
                  :other, :taing, :teaching, :user_id, :windows, :writing

  belongs_to :user

  validates_presence_of :user_id
  validates_uniqueness_of :user_id
end