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
      # rubocop:disable Rails/OutputSafety
      Rails.application.assets.find_asset('test').to_s.html_safe
      # rubocop:enable Rails/OutputSafety
    end
  end
end
