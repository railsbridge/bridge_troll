class Role < ActiveHash::Base
  STUDENT = 1
  VOLUNTEER = 2
  ORGANIZER = 3

  self.data = [
    {:id => STUDENT, :title => "Student"},
    {:id => VOLUNTEER, :title => "Volunteer"},
    {:id => ORGANIZER, :title => "Organizer"}
  ]
end
