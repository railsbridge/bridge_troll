module EventsHelper
  def get_volunteer_skills(volunteer)
    @skills = []
    @skills << 'Teaching'     if(volunteer.teaching)
    @skills << 'TA-ing'       if(volunteer.taing)
    @skills << 'Coordinating' if(volunteer.coordinating)
    @skills << 'Childcare'    if(volunteer.childcaring)
    @skills << 'Writing'      if(volunteer.writing)
    @skills << 'Hacking'      if(volunteer.hacking)
    @skills << 'Designing'    if(volunteer.designing)
    @skills << 'Evangelizing' if(volunteer.evangelizing)
    @skills << 'Mentoring'    if(volunteer.mentoring)
    @skills << 'Mac OS X'     if(volunteer.macosx)
    @skills << 'Windows'      if(volunteer.windows)
    @skills << 'Linux'        if(volunteer.linux)
    @skills.join(', ')
  end

  def teachers(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += volunteer.teaching ? 1 : 0
    end
    count
  end

  def tas(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += volunteer.taing ? 1 : 0
    end
    count
  end

  def organizer_title
   @event.organizers.length > 1 ? "Organizers:" : "Organizer:"
  end

  def organizer_list
    @event.organizers.length == 0 ?  [{:name => "No Organizer Assigned"}] : @event.organizers
  end

end
