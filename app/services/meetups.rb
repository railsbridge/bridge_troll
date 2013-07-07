# encoding: UTF-8

module MeetupEventInfo
  module_function

  def url_for_event meetup_event_id
    MEETUP_EVENTS.each do |group, events|
      if events.find { |event| [event[:student_event_id], event[:volunteer_event_id]].include?(meetup_event_id) }
        return MEETUP_GROUP_URLS[group]
      end
    end
    return nil
  end
end

MEETUP_GROUP_URLS = {
  sf: 'www.sfruby.info',
  sv: 'www.meetup.com/silicon-valley-ruby'
}

MEETUP_GROUP_IDS = {
  sf: 134063,
  sv: 437842
}

MEETUP_EVENTS = {}

MEETUP_EVENTS[:sf] = [
  {
    name: 'Ruby on Rails Outreach Workshop',
    volunteer_event_id: 10527868,
    student_event_id: 10377288
  },
  {
    name: 'Ruby on Rails Outreach Workshop Installfest',
    volunteer_event_id: 10826791,
    student_event_id: 10804417
  },
  {
    name: 'Ruby on Rails Outreach Workshop Workshop',
    volunteer_event_id: 10827608,
    student_event_id: 10804438
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 11307647,
    student_event_id: 11298801
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 12605400,
    student_event_id: 12605445
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 13311831,
    student_event_id: 13358016
  },
  #{
  #    name: 'Ruby on Rails Outreach Workshop for Women',
  #    volunteer_event_id: ,
  #    student_event_id: 14701678
  #},
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 14835957,
    student_event_id: 14836042
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 15493534,
    student_event_id: 15493602
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 16001929,
    student_event_id: 16004702
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 16002033,
    student_event_id: 16002166
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 16605173,
    student_event_id: 16605044
  },
  # crazy eventbrite event
  #{
  #    name: 'Ruby on Rails Outreach Workshop for Women',
  #    volunteer_event_id: 17132464,
  #    student_event_id:
  #},
  # spanish language workshop - no student
  #{
  #    name: 'RailsBridge Taller en Español Reunión de Voluntarios',
  #    volunteer_event_id: 17514882,
  #    student_event_id:
  #},
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 17398873,
    student_event_id: 17398633
  },
  {
    name: 'RailsBridge Taller en Español Reunión de Voluntarios',
    volunteer_event_id: 26110471,
    student_event_id: 24061891
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 28060961,
    student_event_id: 28059391
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 29442521,
    student_event_id: 29387411
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 33543532,
    student_event_id: 33540222
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 39213292,
    student_event_id: 39212752
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 40498612,
    student_event_id: 40498202
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 47101662,
    student_event_id: 47101182
  },
  # first front end workshop - students + vols registered together
  #{
  #    name: 'Ruby on Rails Outreach Workshop for Women',
  #    volunteer_event_id: ,
  #    student_event_id: 52502132
  #},
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 55424432,
    student_event_id: 55417492
  },
  {
    name: 'RailsBridge Outreach for Women Workshop: Learn the Front End!',
    volunteer_event_id: 58304492,
    student_event_id: 58297582
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 60258512,
    student_event_id: 60258772
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 62909402,
    student_event_id: 62910382
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 67302992,
    student_event_id: 67298252
  },
  {
    name: 'San Mateo RailsBridge Workshop for Women',
    volunteer_event_id: 69755072,
    student_event_id: 69860482
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 70892652,
    student_event_id: 70895602
  },
  {
    name: 'Ruby for Beginners',
    volunteer_event_id: 78272032,
    student_event_id: 78271272
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 83965572,
    student_event_id: 83962272
  },
  # bad description, they copied the 'ruby for beginners' one
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 84256812,
    student_event_id: 84256362
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 87955632,
    student_event_id: 87954222
  },
  {
    name: 'RailsBridge Workshop for Women ft. new intermediate Rails curriculum',
    volunteer_event_id: 90076102,
    student_event_id: 90071112
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 94140732,
    student_event_id: 94140352
  },
  {
    name: 'RailsBridge Outreach for Women Workshop: Learn the Front End!',
    volunteer_event_id: 97768552,
    student_event_id: 97765412
  },
  {
    name: 'Intermediate RailsBridge Workshop for Women',
    volunteer_event_id: 95925742,
    student_event_id: 95923212
  },
  {
    name: 'Ruby on Rails Outreach Workshop for Women',
    volunteer_event_id: 99758052,
    student_event_id: 99743792
  },
  {
    name: 'RailsBridge Workshop w Black Founders Beginner and Intermediate Levels',
    volunteer_event_id: 106082842,
    student_event_id: 104829002
  }
]

MEETUP_EVENTS[:sv] = [
  {
    name: "RailsBridge at Outright",
    student_event_id: 106648522,
    volunteer_event_id: 106653212
  },
# second Outright workshop occurred here, but had checkins on bridgetroll proper (http://www.bridgetroll.org/events/39)

# TODO: uncomment and import this google workshop sometime after it occurs (2013-07-12)
#{
#  name: "RailsBridge Ruby on Rails Workshop for Women",
#  student_event_id: 120215942,
#  volunteer_event_id: 120218002
#},
]