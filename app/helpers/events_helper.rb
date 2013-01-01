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
    volunteers.select(&:teaching_only?).count
  end

  def tas_count(volunteers)
    volunteers.select(&:taing_only?).count
  end

  def teach_or_ta_count(volunteers)
    volunteers.select(&:teaching_and_taing?).count
  end

  def not_teach_or_ta_count(volunteers)
    volunteers.select(&:neither_teaching_nor_taing?).count
  end

  def organizer_title
    @event.organizers.length > 1 ? "Organizers:" : "Organizer:"
  end

  def organizer_list
    @event.organizers.length == 0 ?  [{:name => "No Organizer Assigned"}] : @event.organizers
  end

  def partitioned_volunteer_list(volunteers, type)
    partition = volunteers.select(&type)
    content_tag "ol" do
      partition.map { |v| partitioned_volunteer_tag(v) }.join('').html_safe
    end
  end

  def partitioned_volunteer_tag(volunteer)
    content_tag "li","#{volunteer.name} - #{volunteer.email}", :class => volunteer_class(volunteer)
  end

  private

  def volunteer_class(volunteer)
    return "both"  if volunteer.teaching_and_taing?
    return "teach" if volunteer.teaching_only?
    return "ta"    if volunteer.taing_only?
    return "none"  if volunteer.neither_teaching_nor_taing?
  end
end
