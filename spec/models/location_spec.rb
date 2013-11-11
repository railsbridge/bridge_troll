require 'spec_helper'

describe Location do
  it { should have_many(:events) }

  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:address_1) }
  it { should allow_mass_assignment_of(:address_2) }
  it { should allow_mass_assignment_of(:city) }
  it { should allow_mass_assignment_of(:state) }
  it { should allow_mass_assignment_of(:zip) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address_1) }
  it { should validate_presence_of(:city) }
end