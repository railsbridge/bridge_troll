module ApplicationHelper
  include ActiveSupport::Inflector

  def link_for(obj)
    link_to obj.to_s, url_for(obj)
  end

  def day_date_time(time)
    time.strftime("%A %B ") + 
    ordinalize(time.day) + 
    time.strftime(" %Y at %l:%M") + 
    am_pm(time)
  end

  def numeric_date_and_time(time)
    "#{time.month}/#{time.day}" + time.strftime("%l:%M") + am_pm(time)
  end

  def am_pm(time)
    time.strftime("%p").downcase
  end
end
