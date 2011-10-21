pivotal = Location.find_or_create_by_name("Pivotal Labs")
pivotal.update_attributes({
  :address => "731 Market St",
  :city => 'San Francisco',
  :state => 'CA',
  :zipcode => 94108
})

square = Location.find_or_create_by_name("Square")
square.update_attributes({
  :address => "110 5th St",
  :city => 'San Francisco',
  :state => 'CA',
  :zipcode => 94102
})


blazing_cloud = Location.find_or_create_by_name("Blazing Cloud")
blazing_cloud.update_attributes({
  :address => "414 Mason Street, Suite 401",
  :city => 'San Francisco',
  :state => 'CA',
  :zipcode => 94102
})

engine_yard = Location.find_or_create_by_name("Engine Yard")
engine_yard.update_attributes({
  :address => "500 Third St, Suite 510",
  :city => 'San Francisco',
  :state => 'CA',
  :zipcode => 94107
})

may2011 = Event.find_or_create_by_name('May 2011 Ruby on Rails Outreach Workshop for Women')
may2011.update_attributes({
  :location_id => pivotal.id,
  :start_time => DateTime.parse("May 6 2011, 6:30 PST"),
  :end_time => DateTime.parse("May 7 2011, 16:00 PST"),
  :description => %Q(In this workshop, we'll take you through building a complete web application using Ruby on Rails. By the end of the workshop, you'll have an application on the internet that connects to a database and reads and writes information. We'll meet up Install Fest day to install all of the software you need, and then spend workshop day learning and writing code.),
  :capacity => 30,
  :guests_per_user => 1
})


aug2011 = Event.find_or_create_by_name('August 2011 Ruby on Rails Outreach Workshop for Women')
aug2011.update_attributes({
  :location_id => square.id,
  :start_time => DateTime.parse("August 12 2011, 6:30 PST"),
  :end_time => DateTime.parse("August 13 2011, 16:00 PST"),
  :description => %Q(In this workshop, we'll take you through building a complete web application using Ruby on Rails. By the end of the workshop, you'll have an application on the internet that connects to a database and reads and writes information. We'll meet up Install Fest day to install all of the software you need, and then spend workshop day learning and writing code.),
  :capacity => 30,
  :guests_per_user => 1
})


sep2011 = Event.find_or_create_by_name('September 2011 Ruby on Rails Outreach Workshop for Women')
sep2011.update_attributes({
  :location_id => pivotal.id,
  :start_time => DateTime.parse("September 9 2011, 6:30 PST"),
  :end_time => DateTime.parse("September 10 2011, 16:00 PST"),
  :description => %Q(In this workshop, we'll take you through building a complete web application using Ruby on Rails. By the end of the workshop, you'll have an application on the internet that connects to a database and reads and writes information. We'll meet up Install Fest day to install all of the software you need, and then spend workshop day learning and writing code.),
  :capacity => 30,
  :guests_per_user => 1
})



Role.find_or_create_by_name("Organizer")
Role.find_or_create_by_name("Volunteer")

