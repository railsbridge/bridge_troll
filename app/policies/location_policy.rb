class LocationPolicy < ApplicationPolicy
  def destroy?
    record.events.count == 0
  end

  def archive?
    return false unless record.persisted?
    return false if record.archived?
    update? || edit_additional_details?
  end

  def update?
    return true if record.events_count == 0
    return true if user.admin?

    record.notable_events.map(&:organizers).flatten.map(&:id).include?(user.id)
  end

  def edit_additional_details?
    record.region&.has_leader?(user)
  end

  def permitted_attributes
    attributes = [
      :name,
      :address_1,
      :address_2,
      :city,
      :state,
      :zip,
      :region_id
    ]
    if edit_additional_details?
      attributes += [
        :contact_info,
        :notes
      ]
    end
    attributes
  end
end