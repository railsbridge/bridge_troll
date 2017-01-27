module LocationsHelper

  def pretty_print_address location
    safe_join(location_array(location).map { |line| content_tag(:div, line) }, '')
  end

  def location_map_link location
    "http://maps.google.com/?q=#{Rack::Utils.escape(location.full_address)}"
  end

  private

  def location_array location
    [
      location.name,
      location.address_1,
      location.address_2.present? ? location.address_2 : nil,
      "#{location.city}, #{location.state} #{location.zip}"
    ].compact
  end
end