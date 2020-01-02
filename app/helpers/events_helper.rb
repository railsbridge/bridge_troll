# frozen_string_literal: true

module EventsHelper
  def field_classes(event, field)
    ['field'].tap { |classes| classes << 'has-error' if event.errors[field].present? }
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

  def formatted_date(event_or_session)
    l event_or_session.date_in_time_zone(:starts_at), format: :date_as_day_mdy
  end

  def formatted_session_time(event_session, start_or_end)
    l event_session.date_in_time_zone(start_or_end), format: :time_as_hm_ampm
  end

  def formatted_session_fancy_date(event_session)
    "#{l event_session.date_in_time_zone(:starts_at), format: :date_as_day_month_day_year}: #{event_session.name}"
  end

  def formatted_session_timerange(event_session)
    start_time = l event_session.date_in_time_zone(:starts_at), format: :time_as_hm_ampm_no_zone
    end_time = l event_session.date_in_time_zone(:ends_at), format: :time_as_hm_ampm_no_zone
    zone = l event_session.date_in_time_zone(:starts_at), format: :time_zone
    "#{start_time} - #{end_time} #{zone}"
  end

  def simple_format_with_html(string)
    # remove unsightly </h2>\n<br/> combos
    simple_format(Sanitize.clean(string, Sanitize::Config::RELAXED), sanitize: false)
      .gsub(%r{(</h\d>|</li>|<ul>|<li>)\s*<br\s*/>}, '\1').html_safe # rubocop:disable Rails/OutputSafety
  end

  def imported_event_popover_trigger(event)
    if event.imported_event_data
      content_tag(:button, '?', class: 'imported-event-popover-trigger', data: { event_id: event.id })
    end
  end

  def pretty_print_session(session)
    "#{session.name} on #{formatted_date(session)} from #{formatted_session_timerange(session)}"
  end

  def verb(role)
    role == Role::STUDENT ? 'attending' : 'volunteering at'
  end

  def student_attend_button_text(event)
    event.students_at_limit? ? 'Join the student waitlist' : 'Attend as a student'
  end

  def volunteer_attend_button_text(event)
    event.volunteers_at_limit? ? 'Join the volunteer waitlist' : 'Volunteer'
  end

  def google_calendar_event_url(event, event_session)
    params = {
      'action' => 'TEMPLATE',
      'text' => "#{event.title}: #{event_session.name}",
      'dates' => [event_session.starts_at, event_session.ends_at].map { |date| date.utc.strftime('%Y%m%dT%H%M00Z') }.join('/'),
      'details' => "more details here: #{event_url(event)}"
    }

    URI::HTTP.build(host: 'www.google.com', path: '/calendar/event', query: params.to_query).to_s
  end

  def user_gravatar(user)
    gravatar_image_tag(user.email, alt: '', gravatar: { size: 38 })
  end

  def event_special_permissions_text(event, user_event_role)
    if current_user.admin?
      return 'As an admin, you can view organizer tools for this event.'
    elsif event.chapter.has_leader?(current_user)
      return "As a chapter leader for #{event.chapter.name}, you can view organizer tools for this event."
    elsif event.organization.has_leader?(current_user)
      return "As an organization leader for #{event.organization.name}, you can view organizer tools for this event."
    end

    role_text = user_event_role == :editor ? 'an organizer of' : 'a checkiner for'
    "You are #{role_text} this event!"
  end

  def event_form_section(label:, form:, force_expanded: false)
    toggler_classes = ['form-section-header']
    section_classes = ['collapse']
    if form.object.published? || force_expanded
      section_classes << 'in'
    else
      toggler_classes << 'collapsed'
    end

    id = "section-#{label}".parameterize
    results = []
    results << content_tag('a', class: toggler_classes, data: { toggle: 'collapse', target: "##{id}" }) { label }
    results << content_tag('section', id: id, class: section_classes.join(' ')) { yield }

    safe_join(results, "\n")
  end
end
