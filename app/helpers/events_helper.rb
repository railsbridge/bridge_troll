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

  def teachers_count(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += volunteer.teaching && !volunteer.taing ? 1 : 0
    end
    count
  end

  def tas_count(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += volunteer.taing && !volunteer.teaching ? 1 : 0
    end
    count
  end

  def teach_or_ta_count(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += volunteer.taing && volunteer.teaching ? 1 : 0
    end
    count
  end

  def not_teach_or_ta_count(volunteers)
    count = 0
    volunteers.each do |volunteer|
      count += !volunteer.taing && !volunteer.teaching ? 1 : 0
    end
    count
  end


  def organizer_title
   @event.organizers.length > 1 ? "Organizers:" : "Organizer:"
  end

  def organizer_list
    @event.organizers.length == 0 ?  [{:name => "No Organizer Assigned"}] : @event.organizers
  end

  def volunteer_display(volunteer, *attributes)
    volunteer_class = ""
    if attributes.length == 2
      if volunteer.send(attributes[0]) && volunteer.send(attributes[1])
        volunteer_class = "both"
      end
    end

    if attributes.length == 1 && attributes[0] == "teaching"
      if volunteer.send(attributes[0]) && !volunteer.taing
        volunteer_class = "teach"
      end
    end

    if attributes.length == 1 && attributes[0] == "taing"
      if volunteer.send(attributes[0]) && !volunteer.teaching
        volunteer_class = "ta"
      end
    end

    if attributes.length == 0
      if !volunteer.taing && !volunteer.teaching
        volunteer_class = "none"
      end
    end
    get_tag volunteer, volunteer_class unless volunteer_class.empty?
  end

  private

  def get_tag(volunteer, volunteer_class)
    content_tag "li","#{volunteer.name} - #{volunteer.email}", :class => volunteer_class
  end

end
