# frozen_string_literal: true

class ProfilePolicy < ApplicationPolicy
  def permitted_attributes
    %i[
      childcaring
      designing
      outreach
      linux
      macosx
      mentoring
      other
      windows
      writing
      bio
      github_username
      twitter_username
    ]
  end
end
