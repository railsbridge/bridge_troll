class SectionPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :name,
      :class_level
    ]
  end
end