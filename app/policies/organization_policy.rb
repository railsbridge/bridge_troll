# frozen_string_literal: true

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
    user&.admin?
  end

  def manage_organization?
    user && (user.admin? || record.leader?(user))
  end

  def permitted_attributes
    [
      :name
    ]
  end
end
