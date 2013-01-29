module ProfilesHelper

  def skills
    [ 
      [:coordinating, "Coordinator"],
      [:childcaring, "Childcare"],
      [:writing, "Writer"],
      [:hacking, "Hacker"],
      [:designing, "Designer"],
      [:evangelizing, "Evangelize"],
      [:mentoring, "Mentor"],
      [:macosx, "Mac OS X"],
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