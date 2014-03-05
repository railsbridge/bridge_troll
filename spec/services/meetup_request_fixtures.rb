module MeetupRequestFixtures
  def self.rsvp_response options
    event_id = options[:event_id]
    waitlisted = options[:waitlisted] || []
    response = {
      "results" => [
        {
          "response" => "yes",
          "member" => {
            "name" => options[:attendees].first[:name],
            "member_id" => options[:attendees].first[:id]
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
            "id" => "#{event_id}",
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
            "name" => options[:attendees].last[:name],
            "member_id" => options[:attendees].last[:id]
          },
          "host" => false,
          "created" => 1357543103000,
          "event" => {
            "id" => "#{event_id}",
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
            "name" => options[:organizer][:name],
            "member_id" => options[:organizer][:id]
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
            "id" => "#{event_id}",
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
            "id" => "#{event_id}",
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
    waitlisted.each do |student|
      response['results'] << {
        "response" => "waitlist",
        "member" => {
          "name" => student[:name],
          "member_id" => student[:id]
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
          "id" => "#{event_id}",
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
      }
    end

    response
  end

  def self.event_response options
    event_id = options[:event_id]
    {
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
      "id" => "#{event_id}",
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
end
