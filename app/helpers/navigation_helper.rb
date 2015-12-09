module NavigationHelper
  def crud_object_nav_links(current_object, authenticated_link = nil)
    [].tap do |result|
      result << authenticated_link if authenticated_link && user_signed_in?
      result << ['Locations', locations_path] unless current_object == :location
      result << ['Chapters', chapters_path] unless current_object == :chapter
      result << ['Regions', regions_path] unless current_object == :region
      result << ['Events', events_path]
    end
  end
end
