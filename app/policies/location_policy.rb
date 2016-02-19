class LocationPolicy < ApplicationPolicy
  def destroy?
    record.events.count == 0
  end

  def archive?
    record.archivable_by?(user)
  end

  def edit?
    record.editable_by?(user)
  end
end