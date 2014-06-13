require 'rails_helper'

def event_for_dates(starts_at, ends_at)
  event = build(:event_with_no_sessions)
  event.event_sessions << build(:event_session, event: @event, starts_at: starts_at, 
    ends_at: 4.hours.since(starts_at) )

  event.event_sessions << build(:event_session, event: @event, starts_at: 4.hours.until(ends_at),
    ends_at: ends_at )

  event.save
  event
end

describe EventsHelper do
  describe "#formatted_event_date_range(event)" do

    context "when called with an event occurring in a single month" do
      before(:each) do
        @event = event_for_dates( DateTime.parse('2013-02-12'),
                                  DateTime.parse('2013-02-14'))
      end

      it "should return a string with that month once" do
        #off by a day because of time zones
        helper.formatted_event_date_range(@event).should == "Feb 11-13 2013"
      end
    end

    context "when called with an event occuring across two months but one year" do
      before(:each) do
        @event = event_for_dates( DateTime.parse('2013-02-27'),
                                  DateTime.parse('2013-03-02'))
      end

      it "should return a string with both of those months but one year" do
        #off by a day because of time zones
        helper.formatted_event_date_range(@event).should == "Feb 26-Mar 1 2013"
      end
    end

    context "when called with an event occuring across two years" do
       before(:each) do
        @event = event_for_dates( DateTime.parse('2013-12-30'), 
                                  DateTime.parse('2014-01-02'))
      end


      it "should return a string with both months and years" do
        #off by a day because of time zones
        helper.formatted_event_date_range(@event).should == "Dec 29 2013-Jan 1 2014"
      end
    end
  end
end