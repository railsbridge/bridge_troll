module ApplicationHelper
  def format_time(time)
    time.strftime('%I:%M %p')
  end
  
  def format_date(date)
    date.strftime('%b %d, %Y')
  end
end
