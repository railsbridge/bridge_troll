module LocationsHelper

  def pretty_print_address location
    tags = location_array(location).map { |line| content_tag(:div, line) }
    tags.join('').html_safe
  end

  private

  def location_array location
    address = []
    address.push location.name
    address.push location.address_1
    address.push location.address_2 unless location.address_2.blank?
    address.push "#{location.city}, #{location.state} #{location.zip}"
    return address
  end
end