# frozen_string_literal: true

class RegionPolicy < ApplicationPolicy
  def update?
    record.has_leader?(user)
  end

  def modify_leadership?
    record.has_leader?(user)
  end

  def permitted_attributes
    [
      :name
    ]
  end
end
