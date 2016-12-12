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
      :allow_event_email
    ]
  end
end