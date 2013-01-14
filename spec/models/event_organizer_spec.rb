require 'spec_helper'

describe EventOrganizer do
  it { should belong_to(:event) }
  it { should belong_to(:user) }

  it { should allow_mass_assignment_of(:event_id) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should validate_presence_of(:event_id) }
  it { should validate_presence_of(:user_id) }

  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
end
