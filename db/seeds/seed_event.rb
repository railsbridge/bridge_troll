require 'faker'

module Seeder
  def self.create_user email
    user = User.create!(
      email: email,
      password: 'password',
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name
    )
    user.confirm!
    user
  end

  def self.create_volunteer_rsvp options
    rsvp = Rsvp.create!(
      event: options[:event],
      user: options[:user],
      role: Role::VOLUNTEER,
      volunteer_assignment: options[:assignment],
      subject_experience: Faker::Lorem.sentence,
      teaching_experience: Faker::Lorem.sentence,
      job_details: Faker::Name.title
    )
    options[:event].event_sessions.each do |session|
      RsvpSession.create!(rsvp: rsvp, event_session: session)
    end
  end

  def self.create_student_rsvp options
    rsvp = Rsvp.create!(
      event: options[:event],
      user: options[:user],
      waitlist_position: options[:waitlist_position],
      role: Role::STUDENT,
      operating_system: OperatingSystem::OSX_LION,
      class_level: options[:class_level]
    )
    options[:event].event_sessions.each do |session|
      RsvpSession.create!(rsvp: rsvp, event_session: session)
    end
  end

  def self.destroy_event event
    event.rsvps.each do |rsvp|
      if rsvp.user.rsvps.length == 1
        rsvp.user.destroy
      end
    end
    event.location.destroy if event.location.present?
    event.destroy
  end

  def self.seed_event
    old_event = Event.where(title: 'Seeded Test Event').first
    destroy_event(old_event) if old_event.present?

    location = Location.create!(
      name: "Sutro Tower",
      address_1: "Sutro Tower",
      city: "San Francisco",
      state: "CA",
      zip: "94131",
      latitude: 37.75519999999999,
      longitude: -122.4528,
      gmaps: true
    )

    event = Event.new(
      title: 'Seeded Test Event',
      student_rsvp_limit: 5,
      time_zone: 'Pacific Time (US & Canada)',
      details: <<DETAILS
<h2>Workshop Description</h2>

This workshop is created by seeds.rb. It is to help you see what it looks like to have an event with multiple people RSVPed.

<h2>Location and Sponsors</h2>

The location of this workshop is located in the Cloud. That is where it is located.

<h2>Transportation and Parking</h2>

You can park in this workshop if you are able to fly an airship into the cloud. Otherwise, parking is restricted.

<h2>Food and Drinks</h2>

Food will be provided by you, if you bring it in a knapsack.

<h2>Childcare</h2>

Childcare will not be provided.

<h2>Afterparty</h2>

The afterparty will be at the Fancy Goat at 7:09 PM.

DETAILS
    )
    event.event_sessions << EventSession.create(name: 'First Session', starts_at: 60.days.from_now, ends_at: 61.days.from_now)
    event.event_sessions << EventSession.create(name: 'Second Session', starts_at: 65.days.from_now, ends_at: 66.days.from_now)

    event.location = location

    event.save!

    first_session = event.event_sessions.find_by_name('First Session')
    second_session = event.event_sessions.find_by_name('Second Session')

    organizer = create_user('organizer@example.com')
    event.organizers << organizer

    teacher = create_user('teacher@example.com')
    create_volunteer_rsvp(event: event, user: teacher, assignment: VolunteerAssignment::TEACHER)

    ta = create_user('ta@example.com')
    create_volunteer_rsvp(event: event, user: ta, assignment: VolunteerAssignment::TA)

    unassigned1 = create_user('unassigned1@example.com')
    create_volunteer_rsvp(event: event, user: unassigned1, assignment: VolunteerAssignment::UNASSIGNED)

    unassigned2 = create_user('unassigned2@example.com')
    create_volunteer_rsvp(event: event, user: unassigned2, assignment: VolunteerAssignment::UNASSIGNED)

    (1..5).each do |index|
      student = create_user("student#{index}@example.com")
      create_student_rsvp(event: event, user: student, class_level: index)
    end

    waitlisted = create_user("waitlisted@example.com")
    create_student_rsvp(event: event, user: waitlisted, class_level: 2, waitlist_position: 1)

    event
  end
end