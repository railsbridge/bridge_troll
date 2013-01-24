require 'spec_helper'

describe VolunteerRsvp do
  it { should belong_to(:user) }
  it { should belong_to(:event) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
  it { should validate_presence_of(:user)}
  it { should validate_presence_of(:event)}
end
