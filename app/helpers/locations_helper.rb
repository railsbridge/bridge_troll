module LocationsHelper

  def pretty_print_address location
    loc = location_array(location)
    pretty_address = ""

    loc.each do |line|
      pretty_address += content_tag( :span, line )
    end

    return pretty_address.html_safe
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