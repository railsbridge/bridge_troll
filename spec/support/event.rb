def create_event_with_app(options = {})
  options = {
    :name => "test",
    :location => Location.first.name,
    :start_time => Time.now,
    :end_time => Time.new
  }.merge(options)

  fill_in "event[name]", :with => options[:name]
  select(options[:location], :from => "event[location_id]")
  fill_in "event[start_time]", :with => options[:start_time]
  fill_in "event[end_time]", :with => options[:end_time]

  click_button "Create event"
  return Event.last
end

def create_event
  location = Location.create(:name => "Somewhere")
  Event.create(:start_time => Time.now + 1.hour, :end_time => Time.now + 2.hours, 
    :name => "Workshoppy Thing", :location => location)
end