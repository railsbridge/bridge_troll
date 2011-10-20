module CoreHelper
  def create_event(options = {})
    visit new_event_path

    name = defaulted_option(options[:name], "test")
    fill_in "event[name]", :with => options[:name] || "test"

    location = defaulted_option(options[:location], Location.first.name)
    select(location, :from => "event[location_id]")

    click_button "Create event"
    return Event.last
  end

  def defaulted_option(option, default)
    return !option.nil?? option : default
  end
end
