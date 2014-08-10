module ApplicationHelper
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def test_only_stylesheet
    content_tag :style do
      Rails.application.assets.find_asset('test').to_s.html_safe
    end
  end
end
