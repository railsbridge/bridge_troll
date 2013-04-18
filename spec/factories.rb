FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "example#{n}@example.com"}
    confirmed_at DateTime.now
    password "password"
  end

  factory :meetup_user do
    full_name { "#{Faker::Name.first_name} #{Faker::Name.last_name} (Meetup)" }
    sequence(:meetup_id) { |n| n }
  end

  factory :event_with_no_sessions, :class => Event do
    sequence(:title) { |n| "Event #{n}" }
    details "This is note in the details attribute."
    time_zone "Hawaii"

    factory :event do
      event_sessions { [create(:event_session)] }
    end
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:address_1) { |n| "#{n} Street" }
    city "San Francisco"
  end
  
  factory :event_session do
    sequence(:name) { |n| "Test Session #{n}" }
    starts_at DateTime.now
    ends_at (DateTime.now + 1.day)
  end

  factory :role do
    sequence(:title) { "Teacher Level #{n}" }
  end

  factory :rsvp do
    user 
    event
    role Role.find_by_title('Volunteer')
    teaching_experience "Quite experienced"
    subject_experience "Use professionally"
    childcare_info "Bobby: 8\nSusie: 4"

    factory :student_rsvp do
      role Role.find_by_title 'Student'
      operating_system OperatingSystem::OSX_LION
      class_level 2
    end
  end

  factory :rsvp_session do
    rsvp
    event_session
  end 
end
