module ProfilesHelper

  def skills
    [ 
      [:childcaring, "Childcare"],
      [:writing, "Writer"],
      [:designing, "Designer"],
      [:mentoring, "Mentor"],
      [:macosx, "Mac OS X"],
      [:outreach],
      [:windows],
      [:linux]
    ]
  end

  def skill_title(skill)
    skill[1].blank? ? skill[0].to_s.titlecase : skill[1]
  end

  def skill_symbol(skill)
    skill[0]
  end

end