# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module OmniauthResponses
  def self.meetup_response(meetup_id = 123_456)
    meetup_name = 'Franz Meetuper'
    {
      'provider' => 'meetup',
      'uid' => meetup_id,
      'info' => {
        'id' => meetup_id,
        'name' => meetup_name,
        'photo_url' => 'http://photos1.meetupstatic.com/photos/member/7/7/f/2/member_6510706.jpeg',
        'urls' => {
          'public_profile' => "http://www.meetup.com/members/#{meetup_id}"
        },
        'description' => nil,
        'location' => 'San Francisco, CA, us'
      },
      'credentials' => {
        'token' => '09735fc8a27029e500206e3725b5b0af',
        'refresh_token' => '65dfac4c388c69f3384b219920a52c65',
        'expires_at' => 1_362_299_003,
        'expires' => true
      },
      'extra' => {
        'raw_info' => {
          'lon' => -122.41999816894531,
          'link' => "http://www.meetup.com/members/#{meetup_id}",
          'state' => 'CA',
          'self' => {
            'common' => {}
          },
          'lang' => 'en_US',
          'photo' => {
            'photo_link' => 'http://photos1.meetupstatic.com/photos/member/7/7/f/2/member_6510706.jpeg',
            'highres_link' => 'http://photos1.meetupstatic.com/photos/member/7/7/f/2/highres_6510706.jpeg',
            'thumb_link' => 'http://photos1.meetupstatic.com/photos/member/7/7/f/2/thumb_6510706.jpeg',
            'photo_id' => 6_510_706
          },
          'city' => 'San Francisco',
          'country' => 'us',
          'id' => meetup_id,
          'visited' => 1_362_294_758_000,
          'topics' => [],
          'joined' => 1_233_104_345_000,
          'name' => meetup_name,
          'other_services' => {},
          'lat' => 37.790000915527344
        }
      }
    }
  end

  def self.facebook_response
    {
      provider: 'facebook',
      uid: '1234567',
      info: {
        nickname: 'jbloggs',
        email: 'joe@bloggs.com',
        name: 'Joe Bloggs',
        first_name: 'Joe',
        last_name: 'Bloggs',
        image: 'http://graph.facebook.com/1234567/picture?type=square',
        urls: { Facebook: 'http://www.facebook.com/jbloggs' },
        location: 'Palo Alto, California',
        verified: true
      },
      credentials: {
        token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
        expires_at: 1_321_747_205, # when the access token expires (it always will)
        expires: true # this will always be true
      },
      extra: {
        raw_info: {
          id: '1234567',
          name: 'Joe Bloggs',
          first_name: 'Joe',
          last_name: 'Bloggs',
          link: 'http://www.facebook.com/jbloggs',
          username: 'jbloggs',
          location: { id: '123456789', name: 'Palo Alto, California' },
          gender: 'male',
          email: 'joe@bloggs.com',
          timezone: -8,
          locale: 'en_US',
          verified: true,
          updated_time: '2011-11-11T06:21:03+0000'
        }
      }
    }
  end

  def self.twitter_response
    {
      provider: 'twitter',
      uid: '123456',
      info: {
        nickname: 'johnqpublic',
        name: 'John Q Public',
        location: 'Anytown, USA',
        image: 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
        description: 'a very normal guy.',
        urls: {
          Website: nil,
          Twitter: 'https://twitter.com/johnqpublic'
        }
      },
      credentials: {
        token: 'a1b2c3d4...', # The OAuth 2.0 access token
        secret: 'abcdef1234'
      },
      extra: {
        access_token: '', # An OAuth::AccessToken object
        raw_info: {
          name: 'John Q Public',
          listed_count: 0,
          profile_sidebar_border_color: '181A1E',
          url: nil,
          lang: 'en',
          statuses_count: 129,
          profile_image_url: 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
          profile_background_image_url_https: 'https://twimg0-a.akamaihd.net/profile_background_images/229171796/pattern_036.gif',
          location: 'Anytown, USA',
          time_zone: 'Chicago',
          follow_request_sent: false,
          id: 123_456,
          profile_background_tile: true,
          profile_sidebar_fill_color: '666666',
          followers_count: 1,
          default_profile_image: false,
          screen_name: '',
          following: false,
          utc_offset: -3600,
          verified: false,
          favourites_count: 0,
          profile_background_color: '1A1B1F',
          is_translator: false,
          friends_count: 1,
          notifications: false,
          geo_enabled: true,
          profile_background_image_url: 'http://twimg0-a.akamaihd.net/profile_background_images/229171796/pattern_036.gif',
          protected: false,
          description: 'a very normal guy.',
          profile_link_color: '2FC2EF',
          created_at: 'Thu Jul 4 00:00:00 +0000 2013',
          id_str: '123456',
          profile_image_url_https: 'https://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
          default_profile: false,
          profile_use_background_image: false,
          entities: {
            description: {
              urls: []
            }
          },
          profile_text_color: '666666',
          contributors_enabled: false
        }
      }
    }
  end

  def self.github_response
    {
      provider: 'github',
      uid: '123456',
      info: {
        nickname: 'tjgrathwell',
        email: 'ffjords@example.com',
        name: 'Fancy Fjords'
      }
    }
  end

  def self.google_oauth2_response
    {
      provider: 'google_oauth2',
      uid: '123456789101112130122',
      info: {
        email: 'joe@bloggs.com',
        first_name: 'Joe',
        image: 'https://robohash.org/sitsequiquia.png?size=512x512',
        last_name: 'Bloggs',
        name: 'Joe Bloggs',
        urls: { Google: 'https://plus.google.com/494850544950524948535348525457565050575557' }
      },
      credentials: {
        expires: true,
        expires_at: 1_450_062_184,
        refresh_token: 'XYZW...',
        token: 'ABCDEF...'
      },
      extra: {
        id_info: {
          at_hash: 'abcdefg',
          aud: '50906091245.apps.googleusercontent.com',
          azp: '50906091245.apps.googleusercontent.com',
          email: 'joe@bloggs.com',
          email_verified: true,
          exp: 1_450_062_184,
          iat: 1_450_058_584,
          iss: 'accounts.google.com',
          sub: '102612410550469822979'
        },
        id_token: 'abcdefghijklmnopqrstuvwxyz',
        raw_info: {
          email: 'joe@bloggs.com',
          email_verified: 'true',
          family_name: 'Bloggs',
          gender: 'male',
          given_name: 'Joe',
          kind: 'plus#personOpenIdConnect',
          locale: 'en',
          name: 'Joe Bloggs',
          picture: 'https://robohash.org/sitsequiquia.png?size=512x512',
          profile: 'https://plus.google.com/494850544950524948535348525457565050575557',
          sub: '494850544950524948535348525457565050575557'
        }
      }
    }
  end
end
# rubocop:enable Metrics/ModuleLength
