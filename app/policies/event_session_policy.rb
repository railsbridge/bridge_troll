class EventSessionPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :starts_at,
      :ends_at,
      :name,
      :required_for_students,
      :volunteers_only,
      :location_overridden,
      :location_id
    ]
  end
end