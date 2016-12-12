class OrganizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.organization_leaderships.map(&:organization_id))
      end
    end
  end

  def create?
    user && user.admin?
  end

  def manage_organization?
    user && (user.admin? || record.has_leader?(user))
  end

  def permitted_attributes
    [
      :name
    ]
  end
end
