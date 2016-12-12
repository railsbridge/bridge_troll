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
    user&.admin?
  end

  def modify_leadership?
    update?
  end

  def permitted_attributes
    [
      :name,
      :organization_id
    ]
  end
end