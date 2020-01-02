# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :remember_me,
      :time_zone,
      :gender,
      :allow_event_email,
      :current_password,
      {
        region_ids: [],
        subscribed_organization_ids: [],
        profile_attributes: ProfilePolicy.new(user, Profile).permitted_attributes
      }
    ]
  end
end
