module EventsHelper
  
  def get_volunteer_skills(user_id)
    @user = User.find(user_id)
    @skills = []
    if(@user.teaching)
      @skills << 'Teaching'
    end
    if(@user.taing)
      @skills << 'TA-ing'
    end
    if(@user.coordinating)
      @skills << 'Coordinating'
    end
    if(@user.childcaring)
      @skills << 'Childcaring'
    end
    if(@user.writing)
      @skills << 'Writing'
    end    
    if(@user.hacking)
      @skills << 'Hacking'
    end
    if(@user.designing)
      @skills << 'Designing'
    end
    if(@user.evangelizing)
      @skills << 'Evangelizing'
    end
    if(@user.mentoring)
      @skills << 'Mentoring'
    end
    if(@user.macosx)
      @skills << 'Mac OS X'
    end
    if(@user.windows)
      @skills << 'Windows'
    end
    if(@user.linux)
      @skills << 'Linux'
    end    
    @skills.join(', ')
  end
end
