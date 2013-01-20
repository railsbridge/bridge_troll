class Role < ActiveHash::Base
  self.data = [
    {:id => 1, :title => "Student"},
    {:id => 2, :title => "Volunteer"}
  ]
  VOLUNTEER_ROLE_IDS = [2]

  def self.id_for(role)
    find_by_title(role).id
  end
end
