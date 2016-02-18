class EventPolicy < ApplicationPolicy
  def edit?
    record.editable_by?(user)
  end

  def update?
    record.editable_by?(user)
  end

  def destroy?
    record.editable_by?(user)
  end

  def checkin?
    record.checkiner?(user) || record.chapter.has_leader?(user)
  end

  def see_unpublished?
    user.publisher? || user.admin? || user.chapter_leaderships.present?
  end

  def publish?
    user.publisher? || user.admin? || record.chapter.has_leader?(user)
  end

  def flag?
    user.publisher? || user.admin?
  end

  def admin?
    user.admin?
  end
end