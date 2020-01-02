# frozen_string_literal: true

require 'rails_helper'

describe EventEmail do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:sender).required }

  it { is_expected.to have_many(:event_email_recipients).dependent(:destroy) }
  it { is_expected.to have_many(:recipient_rsvps).through(:event_email_recipients) }
  it { is_expected.to have_many(:recipients).through(:recipient_rsvps).source(:user) }

  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:body) }
end
