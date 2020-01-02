# frozen_string_literal: true

class LevelPolicy < ApplicationPolicy
  def permitted_attributes
    return [] unless user&.admin?

    %i[
      num
      color
      title
      level_description_bullets
      _destroy
    ]
  end
end
