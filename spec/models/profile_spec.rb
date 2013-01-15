require 'spec_helper'

describe Profile do
  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }
  it { should validate_uniqueness_of(:user_id) }

  it { should allow_mass_assignment_of(:childcaring) }
  it { should allow_mass_assignment_of(:coordinating) }
  it { should allow_mass_assignment_of(:designing) }
  it { should allow_mass_assignment_of(:evangelizing) }
  it { should allow_mass_assignment_of(:hacking) }
  it { should allow_mass_assignment_of(:linux) }
  it { should allow_mass_assignment_of(:macosx) }
  it { should allow_mass_assignment_of(:mentoring) }
  it { should allow_mass_assignment_of(:other) }
  it { should allow_mass_assignment_of(:taing) }
  it { should allow_mass_assignment_of(:teaching) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:windows) }
  it { should allow_mass_assignment_of(:writing) }
  it { should allow_mass_assignment_of(:bio) }
end

