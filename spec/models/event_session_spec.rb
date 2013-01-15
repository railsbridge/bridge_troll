require 'spec_helper'

describe EventSession do  
  it { should belong_to(:event) }

  it { should allow_mass_assignment_of(:starts_at) }
  it { should allow_mass_assignment_of(:ends_at) }

  it { should validate_presence_of(:starts_at) }
  it { should validate_presence_of(:ends_at) }

  describe "#date_in_time_zone" do
    before do
      @event = create(:event)
      @session = create(:event_session,
                        event: @event,
                        starts_at: DateTime.parse('Sun, 01 Dec 2013 21:38:00 UTC +00:00'),
                        ends_at: DateTime.parse('Sun, 01 Dec 2013 23:38:00 UTC +00:00'))
    end

    it "returns the date of the event, respecting the event's time zone" do
      @event.time_zone = "Pacific Time (US & Canada)"
      @session.date_in_time_zone(:starts_at).zone.should == 'PST'
      @session.date_in_time_zone(:starts_at).should == DateTime.parse('1/12/2013 1:38 pm PST')

      @event.time_zone = "Eastern Time (US & Canada)"
      @session.date_in_time_zone(:starts_at).zone.should == 'EST'
      @session.date_in_time_zone(:starts_at).should == DateTime.parse('1/12/2013 4:38 pm EST')
    end
  end
end