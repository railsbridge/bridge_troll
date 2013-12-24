FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { ["male", "female", "genderqueer"].sample }
    sequence(:email) { |n| "example#{n}@example.com" }
    confirmed_at DateTime.now
    password "password"
  end

  factory :meetup_user do
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name} (Meetup)" }
    sequence(:meetup_id) { |n| n }
  end

  factory :external_event do
    sequence(:name) { |n| "External Event #{n}" }
    sequence(:location) { |n| "External Event Location #{n}" }
    starts_at DateTime.now
  end

  factory :event_with_no_sessions, :class => Event do
    sequence(:title) { |n| "Event #{n}" }
    details "This is note in the details attribute."
    time_zone "Hawaii"
    starts_at DateTime.now
    ends_at { starts_at + 1.day }
    published true
    student_rsvp_limit 100
    location
    course_id Course::RAILS.id
    volunteer_details "I am some details for volunteers."
    student_details "I am some details for students."

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
    chapter
  end

  factory :chapter do
    sequence(:name) { |n| "Chapter #{n}" }
  end

  factory :event_session do
    sequence(:name) { |n| "Test Session #{n}" }
    starts_at DateTime.now
    ends_at (DateTime.now + 1.day)
  end

  factory :role do
    sequence(:title) { "Teacher Level #{n}" }
  end

  factory :rsvp, aliases: [:volunteer_rsvp] do
    user
    event
    role Role.find_by_title('Volunteer')
    teaching_experience "Quite experienced"
    subject_experience "Use professionally"
    class_level 0
    childcare_info "Bobby: 8\nSusie: 4"
    job_details "Horse whisperer"
    dietary_info "Paleo"

    factory :student_rsvp do
      role Role.find_by_title 'Student'
      operating_system OperatingSystem::OSX_LION
      class_level 2
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
end
