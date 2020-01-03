# frozen_string_literal: true

class ChapterPolicy < ApplicationPolicy
  def new?
    user && (user.admin? || user.organization_leaderships.present?)
  end

  def update?
    record.leader?(user) || record.organization.leader?(user)
  end

  def create?
    update?
  end

  def destroy?
    user&.admin?
  end

  def modify_leadership?
    update?
  end

  def permitted_attributes
    %i[
      name
      organization_id
    ]
  end
end
