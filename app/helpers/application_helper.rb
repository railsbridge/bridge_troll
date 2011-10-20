module ApplicationHelper
  def link_for(obj)
    link_to obj.to_s, url_for(obj)
  end
end
