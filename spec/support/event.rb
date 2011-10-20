def create_event
  location = Location.create(:name => "Somewhere")
  Event.create(:start_time => Time.now + 1.hour, :end_time => Time.now + 2.hours, 
    :name => "Workshoppy Thing", :location => location)
end