class EventPolicy < ApplicationPolicy
  def update?
    return false if record.historical?
    user.admin? || record.organizer?(user) || record.chapter.has_leader?(user) || record.organization.has_leader?(user)
  end

  def edit?
    update?
  end

  def destroy?
    update?
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