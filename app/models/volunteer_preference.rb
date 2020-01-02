# frozen_string_literal: true

class VolunteerPreference < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    { id: 1, name: 'NEITHER', title: 'Non-teaching volunteer' },
    { id: 2, name: 'TEACHER', title: 'Teacher' },
    { id: 3, name: 'TA', title: 'TA' },
    { id: 4, name: 'BOTH', title: 'No Preference' }
  ]
  enum_accessor :name
end
