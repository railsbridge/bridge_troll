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

  def rsvp_class(rsvp)
    rsvp.no_show ? 'no-show' : ''
  end

  def organizer_list
    @event.organizers_with_legacy.empty? ? [] : @event.organizers_with_legacy
  end

  def formatted_session_date(event_session)
    l event_session.date_in_time_zone(:starts_at), :format => :date_as_day_mdy
  end

  def formatted_session_time(event_session, start_or_end)
    l event_session.date_in_time_zone(start_or_end), :format => :time_as_hm_ampm
  end

  def formatted_session_date_and_time(event_session)
    "#{formatted_session_date(event_session)} from #{formatted_session_timerange(event_session)}"
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

  def simple_format_with_html(string)
    simple_format(
      Sanitize.clean(string, Sanitize::Config::RELAXED),
      :sanitize => false
    )
  end

  def formatted_event_date_range(event)
    first_date = event.event_sessions.map { |s| s.date_in_time_zone(:starts_at) }.min
    last_date = event.event_sessions.map { |s| s.date_in_time_zone(:ends_at) }.max

    if first_date.year == last_date.year
      if first_date.month == last_date.month
        t :range_as_month_dayrange_year,
          :month => l(first_date, format: :date_as_m),
          first_day: first_date.day,
          last_day: last_date.day,
          year: first_date.year
      else
        t :range_as_monthrange_year,
          :first_month_day => l(first_date, format: :date_as_m_d),
          :last_month_day => l(last_date, format: :date_as_m_d),
          :year => first_date.year
      end
    else
      t :range_as_yearrange,
        :first_date => l(first_date, format: :date_as_m_d_y),
        :last_date => l(last_date, format: :date_as_m_d_y)
    end
  end

  def pretty_print_session(session)
    p = ''

    p << session.name
    p << " on #{formatted_session_date(session)}"
    p << " from #{formatted_session_timerange(session)}"
  end

  def verb(role)
    role == Role::STUDENT ? "attending" : "volunteering at"
  end

  def attend_button_text(event)
    event.at_limit? ? 'Join the waitlist' : 'Attend as a student'
  end
end
