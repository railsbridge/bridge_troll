class VolunteerAssignment < ActiveHash::Base
  UNASSIGNED = 1
  TEACHER = 2
  TA = 3

  self.data = [
      {:id => UNASSIGNED, :title => "Unassigned"},
      {:id => TEACHER, :title => "Teacher"},
      {:id => TA, :title => "TA"},
  ]
end
