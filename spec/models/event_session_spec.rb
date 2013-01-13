require 'spec_helper'

describe EventSession do  
  it { should belong_to(:event) }

  it { should allow_mass_assignment_of(:starts_at) }
  it { should allow_mass_assignment_of(:ends_at) }

  it { should validate_presence_of(:starts_at) }
  it { should validate_presence_of(:ends_at) }
end