require 'faker'

module Seeder
  def self.create_user email
    user = User.create!(
      email: email,
      password: 'password',
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      time_zone: 'Pacific Time (US & Canada)',
      gender: %w(genderqueer male female trans*).sample
    )
    user.confirm
    user
  end

  def self.create_volunteer_rsvp options
    rsvp_params = {
      role: Role::VOLUNTEER,
      subject_experience: Faker::Lorem.sentence,
      teaching_experience: Faker::Lorem.sentence,
      job_details: Faker::Name.title
    }.merge(options)

    rsvp = Rsvp.new(rsvp_params)
    options[:event].event_sessions.each do |session|
      rsvp.rsvp_sessions.build(event_session: session)
    end
    rsvp.save!
  end

  def self.create_student_rsvp options
    rsvp_params = {
      role: Role::STUDENT,
      operating_system: OperatingSystem.all.sample,
      job_details: Faker::Name.title
    }.merge(options)

    rsvp = Rsvp.new(rsvp_params)
    options[:event].event_sessions.each do |session|
      rsvp.rsvp_sessions.build(event_session: session)
    end
    rsvp.save!
  end

  def self.destroy_event event
    event.rsvps.each do |rsvp|
      if rsvp.user.rsvps.length == 1
        rsvp.user.destroy
      end
    end
    if event.location.present?
      chapter = event.location.chapter
      chapter.destroy if chapter.events.count == 1
      event.location.destroy
    end
    event.destroy
  end

  def self.seed_event(options={})
    students_per_level_range = options[:students_per_level_range] || (3..15)
    old_event = Event.where(title: 'Seeded Test Event').first
    destroy_event(old_event) if old_event.present?

    chapter = Chapter.where(name: 'RailsBridge San Francisco').first_or_create!

    location = Location.create!(
      chapter_id: chapter.id,
      name: "Sutro Tower",
      address_1: "Sutro Tower",
      city: "San Francisco",
      state: "CA",
      zip: "94131",
      latitude: 37.75519999999999,
      longitude: -122.4528,
      gmaps: true)

    event = Event.new(
      title: 'Seeded Test Event',
      student_rsvp_limit: 5,
      time_zone: 'Pacific Time (US & Canada)',
      course_id: Course::RAILS.id,
      location: location,
      current_state: :published,
      target_audience: 'women',
      details: <<-DETAILS.strip_heredoc
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
    event.event_sessions << EventSession.new(name: 'First Session', starts_at: 60.days.from_now, ends_at: 61.days.from_now)
    event.event_sessions << EventSession.new(name: 'Second Session', starts_at: 65.days.from_now, ends_at: 66.days.from_now)

    event.save!

    organizer = create_user('organizer@example.com')
    event.organizers << organizer

    coorganizer = create_user('coorganizer@example.com')
    event.organizers << coorganizer

    teacher = create_user('teacher@example.com')
    create_volunteer_rsvp(event: event, user: teacher, volunteer_assignment: VolunteerAssignment::TEACHER, class_level: 0)

    ta = create_user('ta@example.com')
    create_volunteer_rsvp(event: event, user: ta, volunteer_assignment: VolunteerAssignment::TA, class_level: 3)

    (1..5).each do |level|
      students_in_level = rand(students_per_level_range)
      (1..students_in_level).each do |index|
        student = create_user("student#{level}-#{index}@example.com")
        create_student_rsvp(event: event, user: student, class_level: level)
      end
    end

    student_count = event.student_rsvps.count
    event.update_attribute(:student_rsvp_limit, student_count)

    (1..student_count/3).each do |index|
      volunteer = create_user("volunteer#{index}@example.com")
      volunteer_class_preference = (0..5).to_a.sample
      create_volunteer_rsvp(event: event,
                            user: volunteer,
                            volunteer_assignment: VolunteerAssignment::UNASSIGNED,
                            class_level: volunteer_class_preference,
                            teaching: [true, false].sample,
                            taing: [true, false].sample)
    end

    rand(3..6).times do |n|
      waitlisted = create_user("waitlisted-#{n}@example.com")
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

    User.find_by_email('volunteer1@example.com').rsvps.last.create_survey!(
      good_things: 'The textboxes! Boy, I love filling out textboxes!',
      bad_things: 'Too many terminator robots allowed at the workshop',
      other_comments: 'jolly good show, old bean',
      recommendation_likelihood: 7
    )

    User.find_by_email('student1-1@example.com').rsvps.last.create_survey!(
      good_things: 'I liked the food and also the learning',
      bad_things: "Volunteers could've tried to do a more interesting dance",
      other_comments: 'pip pip, cheerio',
      recommendation_likelihood: 8
    )

    event.update_attribute(:survey_sent_at, DateTime.now)

    event
  end
end
