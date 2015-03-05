class Profile < ActiveRecord::Base
  PERMITTED_ATTRIBUTES = [:childcaring, :designing, :outreach, :linux, :macosx, :mentoring, :other, :windows, :writing, :bio, :github_username]

  belongs_to :user, inverse_of: :profile

  validates_presence_of :user
  validates_uniqueness_of :user_id
end