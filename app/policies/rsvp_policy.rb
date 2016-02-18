class RsvpPolicy < ApplicationPolicy
  def survey?
    record.user == user
  end
end