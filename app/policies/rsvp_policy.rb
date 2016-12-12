class RsvpPolicy < ApplicationPolicy
  def survey?
    record.user == user
  end
  
  def permitted_attributes
    [
      :subject_experience,
      :teaching,
      :taing,
      :teaching_experience,
      :teaching_experience,
      :childcare_info,
      :operating_system_id,
      :job_details,
      :class_level,
      :dietary_info,
      :needs_childcare,
      :plus_one_host
    ]
  end
end