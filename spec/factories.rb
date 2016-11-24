FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { %w(male female genderqueer).sample }
    sequence(:email) { |n| "example#{n}@example.com" }
    confirmed_at DateTime.now
    password "password"

    factory :admin do
      admin true
    end
  end

  factory :meetup_user do
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name} (Meetup)" }
    sequence(:meetup_id) { |n| n }
  end

  factory :external_event do
    sequence(:name) { |n| "External Event #{n}" }
    sequence(:location) { |n| "External Event Location #{n}" }
    sequence(:city) { |n| "External Event City #{n}" }
    starts_at DateTime.now
  end

  factory :event_with_no_sessions, class: Event do
    sequence(:title) { |n| "Event #{n}" }
    details "This is note in the details attribute."
    time_zone "Hawaii"
    starts_at 1.hour.from_now
    ends_at { starts_at + 1.day }
    current_state :published
    student_rsvp_limit 100
    volunteer_rsvp_limit 75
    location
    chapter
    course_id Course::RAILS.id
    volunteer_details "I am some details for volunteers."
    student_details "I am some details for students."
    target_audience "default target audience"
    survey_greeting "Test greeting"

    factory :event do
      before(:create) do |event, evaluator|
        event.event_sessions << build(:event_session, event: event, starts_at: event.starts_at, ends_at: event.ends_at)
      end
    end
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:address_1) { |n| "#{n} Street" }
    city "San Francisco"
    latitude 37.7955458
    longitude -122.3934205
    region
  end

  factory :region do
    sequence(:name) { |n| "Region #{n}" }
  end

  factory :chapter do
    sequence(:name) { |n| "Region #{n}" }
    organization
  end

  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
  end

  factory :event_session do
    sequence(:name) { |n| "Test Session #{n}" }
    starts_at 1.day.from_now
    ends_at { starts_at + 6.hours }
  end

  factory :rsvp, aliases: [:volunteer_rsvp] do
    user
    event
    role Role.find_by_title('Volunteer')
    teaching_experience "Quite experienced"
    subject_experience "Use professionally"
    childcare_info "Bobby: 8\nSusie: 4"
    job_details "Horse whisperer"
    dietary_info "Paleo"

    factory :student_rsvp do
      role Role.find_by_title 'Student'
      operating_system OperatingSystem::OSX_LION
      class_level 2
    end

    factory :teacher_rsvp do
      teaching true
      taing false
      class_level 0
    end

    factory :organizer_rsvp do
      role Role.find_by_title 'Organizer'
    end
    transient do
      session_checkins nil
    end

    after(:build) do |rsvp, evaluator|
      if evaluator.session_checkins
        evaluator.session_checkins.each do |event_session_id, checked_in|
          rsvp.rsvp_sessions << build(:rsvp_session, rsvp: rsvp, event_session_id: event_session_id, checked_in: checked_in)
        end
        rsvp.checkins_count = evaluator.session_checkins.values.select { |v| v }.length
      elsif rsvp.rsvp_sessions.empty?
        rsvp.rsvp_sessions << build(:rsvp_session, rsvp: rsvp, event_session: rsvp.event.event_sessions.first)
      end
    end
  end

  factory :dietary_restriction do
    rsvp
    restriction "gluten-free"
  end

  factory :rsvp_session do
    rsvp
    event_session
  end

  factory :survey do
    rsvp
    good_things "Those dog stickers were great"
    bad_things "More vegan food"
    other_comments "Thank you!"
  end

  factory :event_email do
    event
    association(:sender, factory: :user)
    subject 'hello world'
    body 'this is an exciting email'
  end

  factory :section do
    event
    class_level 1
    sequence(:name) { |n| "sec_#{n}" }
  end
end
