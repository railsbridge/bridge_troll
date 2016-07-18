class OrganizationPolicy < ApplicationPolicy

  def manage_organization?
    user.organization_leader?(record) || user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.organization_leaderships.map(&:organization_id))
      end
    end
  end
end
