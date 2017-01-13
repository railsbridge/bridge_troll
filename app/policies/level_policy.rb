class LevelPolicy < ApplicationPolicy
  def permitted_attributes
    return [] unless user && user.admin?

    [
      :num,
      :color,
      :title,
      :level_description_bullets,
      :_destroy
    ]
  end
end