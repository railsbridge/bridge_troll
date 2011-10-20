module CoreHelper
  def create_event(options = {})
    name = defaulted_option(options[:name], "test")
    fill_in "event[name]", :with => options[:name] || "test"

    location = defaulted_option(options[:location], Location.first.name)
    select(location, :from => "event[location_id]")

    start_time = defaulted_option(options[:start_time], Time.now)
    fill_in "event[start_time]", :with => start_time

    end_time = defaulted_option(options[:end_time], Time.now)
    fill_in "event[end_time]", :with => end_time

    click_button "Create event"
    return Event.last
  end

  def defaulted_option(option, default)
    return !option.nil?? option : default
  end
end
