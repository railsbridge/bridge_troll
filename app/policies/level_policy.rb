class LevelPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def destroy?
    user.admin?
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
      :num,
      :color,
      :title,
      :level_description
    ]
  end
end