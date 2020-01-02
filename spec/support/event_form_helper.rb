# frozen_string_literal: true

module EventFormHelper
  def visit_new_events_form_and_expand_all_sections
    visit '/events/new'
    expand_all_event_sections
  end

  def expand_all_event_sections
    page.find('.form-section-header-expander .expand-all').click
  end

  def fill_in_good_event_details
    fill_in 'event_title', with: good_event_title
    select 'Ruby on Rails', from: 'event_course_id'
    fill_in 'event_student_rsvp_limit', with: 100
    select Chapter.first.name, from: 'event_chapter_id'
    fill_in 'event_details', with: 'This will be a fun event!'
    fill_in 'event_target_audience', with: 'women'

    within '.event-sessions' do
      fill_in 'Session Name', with: good_event_session_name
      fill_in_event_time
    end
    select '(GMT-09:00) Alaska', from: 'event_time_zone'
  end

  def fill_in_event_time(date = 1.month.from_now)
    datepicker_id = find('.datepicker')['id']
    fill_in datepicker_id, with: date.strftime('%Y-%m-%d')

    start_time_selects = all('.start_time')
    start_time_selects[0].select '03 PM'
    start_time_selects[1].select '15'

    end_time_selects = all('.end_time')
    end_time_selects[0].select '05 PM'
    end_time_selects[1].select '45'

    # Dismiss the date picker that might be active from "fill_in [...] session_date"
    end_time_selects[0].click
  end

  def good_event_title
    'PerlBridge'
  end

  def submit_for_approval_button
    'Submit Event For Approval'
  end

  def good_event_session_name
    'My Amazing Session'
  end
end
