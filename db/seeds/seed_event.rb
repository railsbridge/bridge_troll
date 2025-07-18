# frozen_string_literal: true

require 'faker'

# rubocop:disable Metrics/ModuleLength
module Seeder
  def self.find_or_create_user(email)
    existing_user = User.find_by(email: email)
    return existing_user if existing_user

    user = User.create!(
      email: email,
      password: 'password',
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      time_zone: 'Pacific Time (US & Canada)',
      gender: %w[genderqueer male female trans*].sample
    )
    user.confirm
    user
  end

  def self.create_volunteer_rsvp(options)
    rsvp_params = {
      role: Role::VOLUNTEER,
      subject_experience: Faker::Lorem.sentence,
      teaching_experience: Faker::Lorem.sentence,
      job_details: Faker::Job.title
    }.merge(options)

    rsvp = Rsvp.new(rsvp_params)
    options[:event].event_sessions.each do |session|
      rsvp.rsvp_sessions.build(event_session: session)
    end
    rsvp.save!
  end

  def self.create_student_rsvp(options)
    rsvp_params = {
      role: Role::STUDENT,
      operating_system: OperatingSystem.all.to_a.sample,
      job_details: Faker::Job.title
    }.merge(options)

    rsvp = Rsvp.new(rsvp_params)
    options[:event].event_sessions.each do |session|
      rsvp.rsvp_sessions.build(event_session: session)
    end
    rsvp.save!
  end

  def self.destroy_event(event)
    event.rsvps.each do |rsvp|
      rsvp.user.destroy if rsvp.user.rsvps.count == 1
    end
    event.destroy
    if event.location.present?
      event.location.destroy if event.location.events.count.zero?
      region = event.location.region
      region.destroy if region.events.count.zero?
    end

    if event.chapter.present?
      organization = event.chapter.organization
      event.chapter.destroy if event.chapter.events.count.zero?
      organization.reload.destroy if organization.chapters.count.zero?
    end

    num_course_events = event.course&.events&.count
    event.course.destroy if num_course_events.present? && num_course_events.zero?
  end

  def self.seed_event(options = {})
    students_per_level_range = options[:students_per_level_range] || (3..15)
    old_event = Event.where(title: 'Seeded Test Event').first
    destroy_event(old_event) if old_event.present?

    event = Event.new(
      title: 'Seeded Test Event',
      student_rsvp_limit: 5,
      time_zone: 'Pacific Time (US & Canada)',
      course: Course.find_by(name: 'RAILS'),
      location: location,
      chapter: chapter,
      current_state: :published,
      target_audience: 'women',
      details: <<~DETAILS
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
    event.event_sessions << EventSession.new(name: 'First Session', starts_at: 60.days.from_now,
                                             ends_at: 61.days.from_now)
    event.event_sessions << EventSession.new(name: 'Second Session', starts_at: 65.days.from_now,
                                             ends_at: 66.days.from_now)

    event.save!

    event.organizers << organizer
    coorganizer = find_or_create_user('coorganizer@example.com')
    event.organizers << coorganizer

    create_volunteer_rsvp(event: event, user: find_or_create_user('teacher@example.com'),
                          volunteer_assignment: VolunteerAssignment::TEACHER, class_level: 0)
    create_volunteer_rsvp(event: event, user: find_or_create_user('ta@example.com'),
                          volunteer_assignment: VolunteerAssignment::TA, class_level: 3)

    (1..5).each do |level|
      students_in_level = rand(students_per_level_range)
      (1..students_in_level).each do |index|
        student = find_or_create_user("student#{level}-#{index}@example.com")
        create_student_rsvp(event: event, user: student, class_level: level)
      end
    end

    student_count = event.student_rsvps.count
    event.update_attribute(:student_rsvp_limit, student_count)

    boolean = [true, false].freeze
    (1..(student_count / 3)).each do |index|
      volunteer = find_or_create_user("volunteer#{index}@example.com")
      volunteer_class_preference = (0..5).to_a.sample
      create_volunteer_rsvp(event: event,
                            user: volunteer,
                            volunteer_assignment: VolunteerAssignment::UNASSIGNED,
                            class_level: volunteer_class_preference,
                            teaching: boolean.sample,
                            taing: boolean.sample)
    end

    rand(3..6).times do |n|
      waitlisted = find_or_create_user("waitlisted-#{n}@example.com")
      create_student_rsvp(event: event, user: waitlisted, class_level: 2, waitlist_position: n)
    end

    event.event_emails.create!(
      sender: organizer,
      subject: 'Thanks for signing up for this event!',
      body: "One note about this event:\nThis event will be super fun.\n\nGood day!",
      recipient_rsvps: event.student_rsvps
    )

    event.event_emails.create!(
      sender: coorganizer,
      subject: 'Hello volunteers!',
      body: "Remember to bring all your knowledges to the event.\n\nThank you!",
      recipient_rsvps: event.volunteer_rsvps
    )

    User.find_by(email: 'volunteer1@example.com').rsvps.last.create_survey!(
      good_things: 'The textboxes! Boy, I love filling out textboxes!',
      bad_things: 'Too many terminator robots allowed at the workshop',
      other_comments: 'jolly good show, old bean',
      recommendation_likelihood: 7
    )

    User.find_by(email: 'student1-1@example.com').rsvps.last.create_survey!(
      good_things: 'I liked the food and also the learning',
      bad_things: "Volunteers could've tried to do a more interesting dance",
      other_comments: 'pip pip, cheerio',
      recommendation_likelihood: 8
    )

    event.update_attribute(:survey_sent_at, DateTime.now)

    event
  end

  def self.region
    Region.find_or_create_by(name: 'San Francisco')
  end

  def self.session_location
    Location.find_or_create_by(
      region_id: region.id,
      name: 'Ferry Building',
      address_1: 'Ferry Building',
      city: 'San Francisco',
      state: 'CA',
      zip: '94111',
      gmaps: true
    )
  end

  def self.location
    Location.find_or_create_by(
      region_id: region.id,
      name: 'Sutro Tower',
      address_1: 'Sutro Tower',
      city: 'San Francisco',
      state: 'CA',
      zip: '94131',
      gmaps: true
    )
  end

  def self.organizer
    find_or_create_user('organizer@example.com')
  end

  def self.organization
    Organization.find_or_create_by(name: 'RailsBridge')
  end

  def self.chapter
    Chapter.find_or_create_by(name: 'RailsBridge San Francisco', organization: organization)
  end

  def self.seed_multiple_location_event(_options = {})
    old_event = Event.where(title: 'Seeded Multiple Location Event').first
    destroy_event(old_event) if old_event.present?

    event = Event.new(
      title: 'Seeded Multiple Location Event',
      student_rsvp_limit: 15,
      time_zone: 'Pacific Time (US & Canada)',
      course: Course.find_by(name: 'RAILS'),
      location: location,
      chapter: chapter,
      current_state: :published,
      target_audience: 'women',
      details: <<~DETAILS
        This is an example of an event that takes place in multiple locations!
      DETAILS
    )
    event.event_sessions << EventSession.new(name: 'Teacher Training', starts_at: 60.days.from_now,
                                             ends_at: 61.days.from_now, location: session_location)
    event.event_sessions << EventSession.new(name: 'Workshop', starts_at: 65.days.from_now, ends_at: 66.days.from_now)

    event.save!

    event.organizers << organizer

    volunteer = find_or_create_user('volunteer1@example.com')
    create_volunteer_rsvp(event: event,
                          user: volunteer,
                          volunteer_assignment: VolunteerAssignment::UNASSIGNED,
                          class_level: 1,
                          teaching: true,
                          taing: true)

    event
  end

  def self.seed_past_event
    old_event = Event.where(title: 'Seeded Past Event').first
    destroy_event(old_event) if old_event.present?

    event = Event.new(
      title: 'Seeded Past Event',
      student_rsvp_limit: 15,
      time_zone: 'Pacific Time (US & Canada)',
      course: Course.find_by(name: 'RAILS'),
      location: location,
      chapter: chapter,
      current_state: :published,
      target_audience: 'women',
      details: <<~DETAILS
        This is an example of an event that takes place in multiple locations!
      DETAILS
    )

    installfest = EventSession.new(name: 'Installfest', starts_at: 60.days.from_now, ends_at: 61.days.from_now)
    workshop = EventSession.new(name: 'Workshop', starts_at: 62.days.from_now, ends_at: 63.days.from_now)

    event.event_sessions << installfest
    event.event_sessions << workshop

    event.save!

    installfest.update(starts_at: 61.days.ago, ends_at: 60.days.ago)
    workshop.update(starts_at: 60.days.ago, ends_at: 59.days.ago)

    event.organizers << organizer

    volunteer = find_or_create_user('volunteer1@example.com')
    create_volunteer_rsvp(event: event,
                          user: volunteer,
                          volunteer_assignment: VolunteerAssignment::UNASSIGNED,
                          class_level: 1,
                          teaching: true,
                          taing: true)

    event
  end
end
# rubocop:enable Metrics/ModuleLength
