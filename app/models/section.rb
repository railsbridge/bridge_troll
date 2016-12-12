class Section < ActiveRecord::Base
  belongs_to :event
  has_many :rsvps, dependent: :nullify

  def student_rsvps
    rsvps.where(role_id: Role::STUDENT.id)
  end

  def volunteer_rsvps
    rsvps.where(role_id: Role::VOLUNTEER.id)
  end
end
