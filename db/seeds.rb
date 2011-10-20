blazing_cloud = Location.create!({
  :name => "Blazing Cloud",
  :address => "414 Mason Street, Suite 401",
  :city => 'San Francisco',
  :state => 'CA',
  :zipcode => 94102
})

Event.create!({
  :name => 'April Outreach Workshop for Women',
  :location_id => blazing_cloud.id,
  :start_time => DateTime.parse("April 23 2011, 9:00 PST"),
  :end_time => DateTime.parse("April 23 2011, 16:00 PST"),
  :description => %Q(In this workshop, we'll take you through building a complete web application using Ruby on Rails. By the end of the workshop, you'll have an application on the internet that connects to a database and reads and writes information. We'll meet up Install Fest day to install all of the software you need, and then spend workshop day learning and writing code.),
  :capacity => 30,
  :guests_per_user => 1
})

Role.find_or_create_by_name("Organizer")
Role.find_or_create_by_name("Volunteer")

Location.find_or_create_by_name("Pivotal Labs HQ")
