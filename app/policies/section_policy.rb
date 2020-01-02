# frozen_string_literal: true

class SectionPolicy < ApplicationPolicy
  def permitted_attributes
    %i[
      name
      class_level
    ]
  end
end
