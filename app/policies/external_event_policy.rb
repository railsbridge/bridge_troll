class ExternalEventPolicy < ApplicationPolicy
  def edit?
    user.admin? || user.external_event_editor?
  end
end