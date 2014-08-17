class Profile < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:childcaring, :designing, :outreach, :linux, :macosx, :mentoring, :other, :user_id, :windows, :writing, :bio, :github_username]

  belongs_to :user
  

  validates_presence_of :user_id
  validates_uniqueness_of :user_id
end