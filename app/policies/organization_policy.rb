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
end