# frozen_string_literal: true

module ProfilesHelper
  def skills
    [
      [:childcaring, 'Childcare'],
      [:writing, 'Writer'],
      [:designing, 'Designer'],
      [:mentoring, 'Mentor'],
      [:outreach],
      [:macosx, 'Mac OS X'],
      [:windows],
      [:linux]
    ]
  end

  def skills?(user)
    skills.any? { |(skill_symbol, _)| user.profile[skill_symbol] }
  end

  def skill_title(skill)
    skill[1].presence || skill[0].to_s.titlecase
  end

  def skill_symbol(skill)
    skill[0]
  end
end
