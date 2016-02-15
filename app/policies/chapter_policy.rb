class ChapterPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def edit?
    record.has_leader?(user)
  end

  def update?
    record.has_leader?(user)
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def modify_leadership?
    record.has_leader?(user)
  end
end