module EventsHelper
  def get_volunteer_skills(volunteer_rsvp)
    profile = volunteer_rsvp.user.profile
    @skills = []
    @skills << 'Teaching'     if(volunteer_rsvp.teaching)
    @skills << 'TA-ing'       if(volunteer_rsvp.taing)
    @skills << 'Childcare'    if(profile.childcaring)
    @skills << 'Writing'      if(profile.writing)
    @skills << 'Outreach'      if(profile.outreach)
    @skills << 'Designing'    if(profile.designing)
    @skills << 'Mentoring'    if(profile.mentoring)
    @skills << 'Mac OS X'     if(profile.macosx)
    @skills << 'Windows'      if(profile.windows)
    @skills << 'Linux'        if(profile.linux)
    @skills.join(', ')
  end

  def teachers_count(volunteer_rsvps)
    teachers(volunteer_rsvps).count
  end

  def tas_count(volunteer_rsvps)
    tas(volunteer_rsvps).count
  end

  def teach_or_ta_count(volunteer_rsvps)
    teach_or_tas(volunteer_rsvps).count
  end

  def not_teach_or_ta_count(volunteer_rsvps)
    not_teach_or_tas(volunteer_rsvps).count
  end

  def organizer_title
    @event.organizers.length > 1 ? "Organizers:" : "Organizer:"
  end

  def organizer_list
    @event.organizers.length == 0 ?  [] : @event.organizers
  end

  def partitioned_volunteer_list(volunteer_rsvps, type)
    partitioned_rsvps = send(type, volunteer_rsvps)

    content_tag "ol" do
      partitioned_rsvps.map { |v| partitioned_volunteer_tag(v) }.join('').html_safe
    end
  end

  def partitioned_volunteer_tag(rsvp)
    volunteer = rsvp.user
    content_tag "li","#{volunteer.full_name} - #{volunteer.email}", :class => volunteer_class(rsvp)
  end

  def formatted_session_date(event_session)
    l event_session.date_in_time_zone(:starts_at), :format => :date_as_day_mdy
  end

  def formatted_session_time(event_session, start_or_end)
    l event_session.date_in_time_zone(start_or_end), :format => :time_as_hm_ampm
  end

  def formatted_session_timerange(event_session)
    start_time = l event_session.date_in_time_zone(:starts_at), :format => :time_as_hm_ampm_no_zone
    end_time = l event_session.date_in_time_zone(:ends_at), :format => :time_as_hm_ampm_no_zone
    zone = l event_session.date_in_time_zone(:starts_at), :format => :time_zone
    "#{start_time} - #{end_time} #{zone}"
  end

  def formatted_session_datetime(event_session)
    "#{formatted_session_date(event_session)} - #{formatted_session_timerange(event_session)}"
  end

  private

  def volunteer_class(rsvp)
    return "both"  if rsvp.teaching && rsvp.taing
    return "teach" if rsvp.teaching
    return "ta"    if rsvp.taing
    #else...
    "none" 
  end

  def teachers(volunteer_rsvps)
    volunteer_rsvps.where(teaching: true, taing: false)
  end

  def tas(volunteer_rsvps)
    volunteer_rsvps.where(teaching: false, taing: true)
  end

  def teach_or_tas(volunteer_rsvps)
    volunteer_rsvps.where(teaching: true, taing: true)
  end

  def not_teach_or_tas(volunteer_rsvps)
    volunteer_rsvps.where(teaching: false, taing: false)
  end
end
