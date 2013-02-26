require 'spec_helper'

describe MeetupImporter do
  let(:rsvp_response) do
    {
      "results" => [
        {
          "response" => "yes",
          "member" => {
            "name" => "Sven Volunteeren",
            "member_id" => 2599323
          },
          "host" => false,
          "member_photo" => {
            "photo_link" => "http://photos3.meetupstatic.com/photos/member/3/6/a/1/member_613985.jpeg",
            "highres_link" => "http://photos1.meetupstatic.com/photos/member/3/6/a/1/highres_613985.jpeg",
            "thumb_link" => "http://photos1.meetupstatic.com/photos/member/3/6/a/1/thumb_613985.jpeg",
            "photo_id" => 613985
          },
          "created" => 1357314915000,
          "event" => {
            "id" => "97768552",
            "time" => 1358614800000,
            "event_url" => "http://www.meetup.com/sfruby/events/97768552/",
            "name" => "Volunteers: RailsBridge Outreach for Women Workshop: Learn the Front End!"
          },
          "tallies" => {
            "yes" => 41,
            "maybe" => 0,
            "no" => 21,
            "waitlist" => 0
          },
          "mtime" => 1357314915000,
          "guests" => 0,
          "rsvp_id" => 637537142,
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
          "group" => {
            "id" => 134063,
            "group_lat" => 37.790000915527344,
            "group_lon" => -122.41000366210938,
            "join_mode" => "open",
            "urlname" => "sfruby"
          }
        },
        {
          "response" => "yes",
          "member" => {
            "name" => "Sally Voluntally",
            "member_id" => 2604303
          },
          "host" => false,
          "created" => 1357543103000,
          "event" => {
            "id" => "97768552",
            "time" => 1358614800000,
            "event_url" => "http://www.meetup.com/sfruby/events/97768552/",
            "name" => "Volunteers: RailsBridge Outreach for Women Workshop: Learn the Front End!"
          },
          "tallies" => {
            "yes" => 41,
            "maybe" => 0,
            "no" => 21,
            "waitlist" => 0
          },
          "mtime" => 1357543103000,
          "guests" => 0,
          "rsvp_id" => 641080492,
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
          "group" => {
            "id" => 134063,
            "group_lat" => 37.790000915527344,
            "group_lon" => -122.41000366210938,
            "join_mode" => "open",
            "urlname" => "sfruby"
          }
        },
        {
          "response" => "yes",
          "member" => {
            "name" => "Liz Organiz",
            "member_id" => 10603531
          },
          "host" => true,
          "tallies" => {
            "yes" => 41,
            "maybe" => 0,
            "no" => 21,
            "waitlist" => 0
          },
          "mtime" => 1357256838000,
          "guests" => 0,
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
          "member_photo" => {
            "photo_link" => "http://photos3.meetupstatic.com/photos/member/3/2/b/c/member_7872988.jpeg",
            "highres_link" => "http://photos3.meetupstatic.com/photos/member/3/2/b/c/highres_7872988.jpeg",
            "thumb_link" => "http://photos3.meetupstatic.com/photos/member/3/2/b/c/thumb_7872988.jpeg",
            "photo_id" => 7872988
          },
          "created" => 1357256838000,
          "event" => {
            "id" => "97768552",
            "time" => 1358614800000,
            "event_url" => "http://www.meetup.com/sfruby/events/97768552/",
            "name" => "Volunteers: RailsBridge Outreach for Women Workshop: Learn the Front End!"
          },
          "rsvp_id" => 636716432,
          "group" => {
            "id" => 134063,
            "group_lat" => 37.790000915527344,
            "group_lon" => -122.41000366210938,
            "join_mode" => "open",
            "urlname" => "sfruby"
          }
        },
        {
          "response" => "no",
          "member" => {
            "name" => "Soandso Noshow",
            "member_id" => 6840892
          },
          "host" => false,
          "member_photo" => {
            "photo_link" => "http://photos3.meetupstatic.com/photos/member/1/2/5/e/member_58264702.jpeg",
            "highres_link" => "http://photos1.meetupstatic.com/photos/member/1/2/5/e/highres_58264702.jpeg",
            "thumb_link" => "http://photos1.meetupstatic.com/photos/member/1/2/5/e/thumb_58264702.jpeg",
            "photo_id" => 58264702
          },
          "created" => 1357265400000,
          "event" => {
            "id" => "97768552",
            "time" => 1358614800000,
            "event_url" => "http://www.meetup.com/sfruby/events/97768552/",
            "name" => "Volunteers: RailsBridge Outreach for Women Workshop: Learn the Front End!"
          },
          "tallies" => {
            "yes" => 41,
            "maybe" => 0,
            "no" => 21,
            "waitlist" => 0
          },
          "mtime" => 1357265400000,
          "guests" => 0,
          "rsvp_id" => 636906862,
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
          "group" => {
            "id" => 134063,
            "group_lat" => 37.790000915527344,
            "group_lon" => -122.41000366210938,
            "join_mode" => "open",
            "urlname" => "sfruby"
          }
        },
      ],
      "meta" => {
        "lon" => "",
        "count" => 20,
        "signed_url" => "http://api.meetup.com/2/rsvps?_=1361754602467&event_id=97768552&order=event&desc=false&offset=0&callback=jQuery17100847937551128326_1361754592514&format=json&page=20&fields=&sig_id=8765979&sig=a40231e6d12885f1cbd8c4d855f92207a1adc437",
        "link" => "https://api.meetup.com/2/rsvps",
        "next" => "https://api.meetup.com/2/rsvps?key=5f27196a236e16796be11504387616&_=1361754602467&event_id=97768552&order=event&desc=false&offset=1&callback=jQuery17100847937551128326_1361754592514&format=json&page=20&fields=&sign=true",
        "total_count" => 57,
        "url" => "https://api.meetup.com/2/rsvps?key=5f27196a236e16796be11504387616&_=1361754602467&event_id=97768552&order=event&desc=false&offset=0&callback=jQuery17100847937551128326_1361754592514&format=json&page=20&fields=&sign=true",
        "id" => "",
        "title" => "Meetup RSVPs v2",
        "updated" => 1358608456000,
        "description" => "Query for Event RSVPs by event",
        "method" => "RSVPs v2",
        "lat" => ""
      }
    }
  end

  let(:event_response) do
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
  end

  before do
    ENV['MEETUP_API_KEY'] = 'sandwich'
    stub_request(:get, "https://api.meetup.com/2/event/97768552?key=sandwich&sign=true").to_return({body: event_response.to_json})
    stub_request(:get, "https://api.meetup.com/2/rsvps?key=sandwich&sign=true&event_id=97768552&fields=host").to_return({body: rsvp_response.to_json})
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

  it "creates MeetupUser records for users who have RSVPed 'yes' to an event" do
    expect {
      MeetupImporter.new.import_event({volunteer_event_id: 97768552, name: 'Some Amazing Event'})
    }.to change(MeetupUser, :count).by(3)

    event = Event.last

    event.volunteer_rsvps.map { |rsvp| rsvp.user.full_name }.should == ["Sven Volunteeren", "Sally Voluntally"]
    event.organizer_rsvps.map { |rsvp| rsvp.user.full_name }.should == ["Liz Organiz"]

    MeetupUser.where(full_name: 'Sven Volunteeren').first.meetup_id.should == 2599323
    MeetupUser.where(full_name: 'Sally Voluntally').first.meetup_id.should == 2604303
    MeetupUser.where(full_name: 'Liz Organiz').first.meetup_id.should == 10603531
  end

  it "can sanitize invalid utf-8" do
    MeetupImporter.new.sanitize("Here\x92s the timeline").should == 'Heres the timeline'
  end
end