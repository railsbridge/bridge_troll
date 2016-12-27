class EventPolicy < ApplicationPolicy
  class Scope < Scope
    def publishable
      if user.admin? || user.publisher?
        scope.all
      elsif user.organization_leaderships.present?
        organization_ids = user.organization_leaderships.map(&:organization_id)
        chapter_ids = Chapter.where(organization_id: organization_ids).pluck('id')
        scope.where(chapter_id: chapter_ids)
      elsif user.chapter_leaderships.present?
        scope.where(chapter_id: user.chapter_leaderships.map(&:chapter_id))
      end
    end
  end

  def update?
    return false if record.historical?
    user.admin? || record.organizer?(user) || record.chapter.has_leader?(user) || record.organization.has_leader?(user)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def checkin?
    record.checkiner?(user) || record.chapter.has_leader?(user)
  end

  def see_unpublished?
    user.publisher? || user.admin? || user.chapter_leaderships.present? || user.organization_leaderships.present?
  end

  def publish?
    user.publisher? || user.admin? || record.chapter.has_leader?(user) || record.chapter.organization.has_leader?(user)
  end

  def flag?
    user.publisher? || user.admin?
  end

  def admin?
    user.admin?
  end

  def permitted_attributes
    [
      :title,
      :target_audience,
      :location_id,
      :chapter_id,
      :details,
      :time_zone,
      :volunteer_details,
      :public_email,
      :starts_at,
      :ends_at,
      :student_rsvp_limit,
      :volunteer_rsvp_limit,
      :course_id,
      :allow_student_rsvp,
      :student_details,
      :plus_one_host_toggle,
      :email_on_approval,
      :has_childcare,
      :restrict_operating_systems,
      :survey_greeting,
      {
        event_sessions_attributes: EventSessionPolicy.new(user, EventSession).permitted_attributes + [:id],
        allowed_operating_system_ids: []
      }
    ]
  end
end