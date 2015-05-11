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
