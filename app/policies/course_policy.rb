class CoursePolicy < ApplicationPolicy
  def destroy?
    record.events.count == 0 && user.admin?
  end

  def edit?
    update?
  end

  def new?
    create?
  end

  def update?
    user.admin?
  end

  def create?
    user.admin?
  end

  def permitted_attributes
    [
      :name,
      :title,
      :description
    ]
  end
end