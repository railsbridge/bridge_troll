module EventsHelper
  def get_volunteer_skills(volunteer_rsvp)
    profile = volunteer_rsvp.user.profile
    @skills = []
    @skills << 'Teaching'     if volunteer_rsvp.teaching
    @skills << 'TA-ing'       if volunteer_rsvp.taing
    @skills << 'Childcare'    if profile.childcaring
    @skills << 'Writing'      if profile.writing
    @skills << 'Outreach'     if profile.outreach
    @skills << 'Designing'    if profile.designing
    @skills << 'Mentoring'    if profile.mentoring
    @skills << 'Mac OS X'     if profile.macosx
    @skills << 'Windows'      if profile.windows
    @skills << 'Linux'        if profile.linux
    @skills.join(', ')
  end

  def field_classes(event, field)
    ['field'].tap do |classes|
      if event.errors[field].present?
        classes << 'has-error'
      end
    end
  end

  def rsvp_class(rsvp)
    if rsvp.waitlisted?
      'waitlisted'
    elsif rsvp.no_show?
      'no-show'
    else
      ''
    end
  end

  def organizer_list
    @event.organizers_with_legacy.empty? ? [] : @event.organizers_with_legacy
  end

  def locations_for_select
    Location.includes(:region).available.map do |loc|
      time_zone = ActiveSupport::TimeZone::MAPPING.key(loc.inferred_time_zone)
      [loc.name_with_region, loc.id, prompt: true, 'data-inferred-time-zone' => time_zone]
    end
  end

  def formatted_event_date(event)
    l event.date_in_time_zone(:starts_at), format: :date_as_day_mdy
  end

  def formatted_session_date(event_session)
    l event_session.date_in_time_zone(:starts_at), format: :date_as_day_mdy
  end

  def formatted_session_time(event_session, start_or_end)
    l event_session.date_in_time_zone(start_or_end), format: :time_as_hm_ampm
  end

  def formatted_session_fancy_date(event_session)
    fancy_date = l event_session.date_in_time_zone(:starts_at), format: :date_as_day_month_day_year
    "#{fancy_date}: #{event_session.name}"
  end

  def formatted_session_timerange(event_session)
    start_time = l event_session.date_in_time_zone(:starts_at), format: :time_as_hm_ampm_no_zone
    end_time = l event_session.date_in_time_zone(:ends_at), format: :time_as_hm_ampm_no_zone
    zone = l event_session.date_in_time_zone(:starts_at), format: :time_zone
    "#{start_time} - #{end_time} #{zone}"
  end

  def formatted_session_datetime(event_session)
    "#{formatted_session_date(event_session)} - #{formatted_session_timerange(event_session)}"
  end

  # rubocop:disable Rails/OutputSafety
  def simple_format_with_html(string)
    simple_format(
      Sanitize.clean(string, Sanitize::Config::RELAXED),
      sanitize: false
    ).gsub(%r{(</h\d>|</li>|<ul>|<li>)\s*<br\s*/>}, '\1').html_safe # remove unsightly </h2>\n<br/> combos
  end
  # rubocop:enable Rails/OutputSafety

  def imported_event_popover_trigger(event)
    if event.imported_event_data
      content_tag(
        :button,
        '?',
        class: 'imported-event-popover-trigger',
        data: {event_id: event.id}
      )
    end
  end

  def formatted_event_date_range(event)
    first_date = event.event_sessions.map { |s| s.date_in_time_zone(:starts_at) }.min
    last_date = event.event_sessions.map { |s| s.date_in_time_zone(:ends_at) }.max

    if first_date.year == last_date.year
      if first_date.month == last_date.month
        t :range_as_month_dayrange_year,
          month: l(first_date, format: :date_as_m),
          first_day: first_date.day,
          last_day: last_date.day,
          year: first_date.year
      else
        t :range_as_monthrange_year,
          first_month_day: l(first_date, format: :date_as_m_d),
          last_month_day: l(last_date, format: :date_as_m_d),
          year: first_date.year
      end
    else
      t :range_as_yearrange,
        first_date: l(first_date, format: :date_as_m_d_y),
        last_date: l(last_date, format: :date_as_m_d_y)
    end
  end

  def pretty_print_session(session)
    "#{session.name} on #{formatted_session_date(session)} from #{formatted_session_timerange(session)}"
  end

  def verb(role)
    role == Role::STUDENT ? "attending" : "volunteering at"
  end

  def student_attend_button_text(event)
    event.students_at_limit? ? 'Join the student waitlist' : 'Attend as a student'
  end

  def volunteer_attend_button_text(event)
    event.volunteers_at_limit? ? 'Join the volunteer waitlist' : 'Volunteer'
  end

  def state_display(event)
    if event.draft?
      "DRAFT"
    elsif event.published?
      "PUBLISHED"
    else
      "PENDING APPR"
    end
  end

  def google_calendar_event_url(event, event_session)
    params = {}
    params["action"] = "TEMPLATE"
    params["text"] = "#{event.title}: #{event_session.name}"
    params["dates"] = [event_session.starts_at, event_session.ends_at].map {|date| 
      date.utc.strftime('%Y%m%dT%H%M00Z')
    }.join('/')
    params["details"] = "more details here: #{event_url(event)}"

    URI::HTTP.build(host: "www.google.com", path: "/calendar/event", query: params.to_query).to_s
  end

  def user_gravatar(user)
    gravatar_image_tag(user.email, alt: '', gravatar: { size: 38 })
  end

  def event_special_permissions_text(event, user_event_role)
    if current_user.admin?
      return "As an admin, you can view organizer tools for this event."
    elsif event.chapter.has_leader?(current_user)
      return "As a chapter leader for #{event.chapter.name}, you can view organizer tools for this event."
    elsif event.organization.has_leader?(current_user)
      return "As an organization leader for #{event.organization.name}, you can view organizer tools for this event."
    end

    role_text = user_event_role == :editor ? 'an organizer of' : 'a checkiner for'
    "You are #{role_text} this event!"
  end

  def event_form_section(label:, form:, force_expanded: false)
    id = "section-#{label}".parameterize

    results = []

    toggler_classes = ['form-section-header']
    section_classes = ['collapse']
    if form.object.published? || force_expanded
      section_classes << 'in'
    else
      toggler_classes << 'collapsed'
    end

    results << content_tag('a', class: toggler_classes, data: {toggle: 'collapse', target: "##{id}"}) do
      label
    end

    results << content_tag('section', id: id, class: section_classes.join(' ')) do
      yield
    end

    safe_join(results, "\n")
  end
end
