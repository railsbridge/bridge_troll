module ApplicationHelper
  include ActiveSupport::Inflector

  def link_for(obj)
    link_to obj.to_s, url_for(obj)
  end

  def day_date_time(time)
    time.strftime("%A %B ") + 
    ordinalize(time.day) + 
    time.strftime(" %Y at %l:%M") + 
    time.strftime("%p").downcase
  end
end
