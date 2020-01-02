# frozen_string_literal: true

module NavigationHelper
  def sign_in_modal_return_to_params
    return {} if request.path == new_user_registration_path

    { return_to: request.fullpath }
  end

  def crud_object_nav_links(current_object, authenticated_link = nil)
    [].tap do |result|
      result << authenticated_link if authenticated_link && user_signed_in?
      result << ['Locations', locations_path] unless current_object == :location
      result << ['Chapters', chapters_path] unless current_object == :chapter
      result << ['Regions', regions_path] unless current_object == :region
      result << ['Events', events_path]
    end
  end

  def devise_links(*links_to_show)
    link_divs = links_to_show.map do |link_symbol|
      content_tag :div do
        devise_link(link_symbol)
      end
    end
    safe_join(link_divs, "\n")
  end

  private

  def devise_link(link_symbol)
    case link_symbol
    when :sign_up
      link_to 'Sign up', new_registration_path(:user), class: 'sign_up_link'
    when :forgot_password
      link_to 'Forgot your password?', new_password_path(:user)
    when :confirmation_instructions
      link_to "Didn't receive confirmation instructions?", new_confirmation_path(:user)
    end
  end
end
