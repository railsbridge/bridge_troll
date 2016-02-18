class ExternalEventPolicy < ApplicationPolicy
  def edit?
    user.admin?
  end
end