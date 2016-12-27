class ExternalEventPolicy < ApplicationPolicy
  def edit?
    user.admin? || user.external_event_editor?
  end

  def permitted_attributes
    [
      :city,
      :ends_at,
      :location,
      :name,
      :organizers,
      :starts_at,
      :url,
      :region_id,
      :chapter_id
    ]
  end
end