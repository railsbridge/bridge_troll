require 'rails_helper'

describe EventMailer do
  let(:event) { create(:event) }

  describe 'the new event email' do
    let(:mail) { EventMailer.new_event(event) }

    it "includes both locations for a multi-location event" do
      event_session = create(:event_session, event: event, location: create(:location))

      expect(mail.body).to include(event_session.location.name)
      expect(mail.body).to include(event.location.name)
    end
  end
end
