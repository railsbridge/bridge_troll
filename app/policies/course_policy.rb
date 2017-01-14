class CoursePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

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
    return [] unless user && user.admin?

    [
      :name,
      :title,
      :description,
      {
        levels_attributes: LevelPolicy.new(user, Level).permitted_attributes + [:id],
      }
    ]
  end
end