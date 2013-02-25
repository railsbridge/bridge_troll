require 'spec_helper'

describe MeetupImporter do
  before do
    ENV['MEETUP_API_KEY'] = 'sandwich'

    event_response = {
        "status" => "past",
        "visibility" => "public",
        "maybe_rsvp_count" => 0,
        "venue" => {
            "id" => 1396916,
            "zip" => "94105",
            "lon" => -122.397664,
            "repinned" => false,
            "name" => "Carbon Five",
            "state" => "CA",
            "address_1" => "585 Howard Street",
            "address_2" => "Floor 2",
            "lat" => 37.787075,
            "city" => "San Francisco ",
            "country" => "us"
        },
        "id" => "97768552",
        "utc_offset" => -28800000,
        "time" => 1358614800000,
        "waitlist_count" => 0,
        "updated" => 1358749097000,
        "yes_rsvp_count" => 41,
        "created" => 1357256837000,
        "event_url" => "http://www.sfruby.info/events/97768552/",
        "description" => "my complicated details",
        "name" => "my imported event",
        "headcount" => 0,
        "rating" => {
            "count" => 5,
            "average" => 4.800000190734863
        },
        "group" => {
            "id" => 134063,
            "group_lat" => 37.790000915527344,
            "name" => "The San Francisco Ruby Meetup Group",
            "group_lon" => -122.41000366210938,
            "join_mode" => "open",
            "urlname" => "sfruby",
            "who" => "Ruby enthusiasts"
        }
    }

    stub_request(:any, "https://api.meetup.com/2/event/97768552?key=sandwich&sign=true").to_return({body: event_response.to_json})
  end

  it "creates Event entries for historical Railsbridge meetup events" do
    expect {
      MeetupImporter.new.import_event({volunteer_event_id: 97768552, name: 'Some Amazing Event'})
    }.to change(Event, :count).by(1)

    Event.last.title.should == 'Some Amazing Event'
    Event.last.details.should == 'my complicated details'
    Event.last.meetup_volunteer_event_id.should == 97768552

    Event.last.location.name.should == 'Carbon Five'
    Event.last.location.address_1.should == '585 Howard Street'
    Event.last.location.address_2.should == 'Floor 2'
    Event.last.location.city.should == 'San Francisco'
    Event.last.location.state.should == 'CA'
    Event.last.location.zip.should == '94105'
  end

  it "creates Location entries for each venue" do
    expect {
      MeetupImporter.new.import_event({volunteer_event_id: 97768552, name: 'Some Amazing Event'})
    }.to change(Location, :count).by(1)
  end

  it "can sanitize invalid utf-8" do
    MeetupImporter.new.sanitize("Here\x92s the timeline").should == 'Heres the timeline'
  end
end