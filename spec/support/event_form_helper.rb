def fill_in_good_event_details
  fill_in 'Title', with: good_event_title
  select "Ruby on Rails", from: "event_course_id"
  fill_in "Student RSVP limit", with: 100
  select Chapter.first.name, from: "event_chapter_id"
  fill_in "event_details", with: "This will be a fun event!"
  fill_in "event_target_audience", with: "women"

  within ".event-sessions" do
    fill_in "Session Name", with: good_event_session_name
    fill_in_event_time
  end
  select "(GMT-09:00) Alaska", from: 'event_time_zone'
end

def fill_in_event_time
  fill_in "event_event_sessions_attributes_0_session_date", with: '2055-01-12'

  start_time_selects = all('.start_time')
  start_time_selects[0].select "03 PM"
  start_time_selects[1].select "15"

  end_time_selects = all('.end_time')
  end_time_selects[0].select "05 PM"
  end_time_selects[1].select "45"

  # Dismiss the date picker that might be active from "fill_in [...] session_date"
  end_time_selects[0].click
end

def good_event_title
  'Linuxless Event'
end

def submit_for_approval_button
  "Submit Event For Approval"
end

def good_event_session_name
  'My Amazing Session'
end
