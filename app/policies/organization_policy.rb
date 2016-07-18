class OrganizationPolicy < ApplicationPolicy

  def manage_organization?
    record.has_leader?(user) || user.admin?
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
