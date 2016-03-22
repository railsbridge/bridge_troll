class ChapterPolicy < ApplicationPolicy
  def new?
    user && (user.admin?|| user.organization_leaderships.present?)
  end

  def update?
    record.has_leader?(user) || record.organization.has_leader?(user)
  end

  def create?
    update?
  end

  def destroy?
    user && user.admin?
  end

  def modify_leadership?
    update?
  end
end