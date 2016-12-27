class ProfilePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :childcaring,
      :designing,
      :outreach,
      :linux,
      :macosx,
      :mentoring,
      :other,
      :windows,
      :writing,
      :bio,
      :github_username,
      :twitter_username
    ]
  end
end