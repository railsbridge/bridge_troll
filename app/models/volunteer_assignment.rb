# frozen_string_literal: true

class VolunteerAssignment < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    { id: 1, name: 'UNASSIGNED', title: 'Unassigned' },
    { id: 2, name: 'TEACHER', title: 'Teacher' },
    { id: 3, name: 'TA', title: 'TA' }
  ]
  enum_accessor :name
end
