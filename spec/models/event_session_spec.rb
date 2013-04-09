require 'spec_helper'

describe EventSession do  
  it { should belong_to(:event) }

  it { should allow_mass_assignment_of(:starts_at) }
  it { should allow_mass_assignment_of(:ends_at) }

  it { should validate_presence_of(:starts_at) }
  it { should validate_presence_of(:ends_at) }

  it { should validate_uniqueness_of(:name).scoped_to(:event_id) }

  describe "#starts_at, #ends_at" do
    it "renders in the event's time zone when there is one" do
      event = create(:event, time_zone: 'Alaska')
      session = event.event_sessions.first
      session.update_attributes(
        starts_at: '2012-02-03 11:41',
        ends_at: '2012-02-04 02:44'
      )
      session.starts_at.time_zone.name.should == 'Alaska'
      session.ends_at.time_zone.name.should == 'Alaska'
    end
  end

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