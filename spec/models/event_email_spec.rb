require 'rails_helper'

describe EventEmail do
  it { should belong_to(:event) }
  it { should belong_to(:sender) }

  it { should have_many(:event_email_recipients).dependent(:destroy) }
  it { should have_many(:recipient_rsvps).through(:event_email_recipients) }
  it { should have_many(:recipients).through(:recipient_rsvps).source(:user) }

  it { should validate_presence_of(:sender) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }
end
