class OrganizationPolicy < ApplicationPolicy

  def manage_organization?
    user && (user.admin? || record.has_leader?(user))
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
