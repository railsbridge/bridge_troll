class ChapterPolicy < ApplicationPolicy
  def new?
    user && (user.admin?|| user.organization_leaderships.present?)
  end

  def edit?
    record.editable_by?(user)
  end

  def update?
    record.editable_by?(user)
  end

  def create?
    user && (user.admin? || record.editable_by?(user))
  end

  def destroy?
    user && user.admin?
  end

  def modify_leadership?
    record.editable_by?(user)
  end
end