FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "example#{n}@example.com"}
    confirmed_at DateTime.now
    password "password"
  end

  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    details "This is note in the details attribute."
    time_zone "Hawaii"

    before(:create) do |event|
      event.event_sessions << create(:event_session)
    end

    factory :event_with_no_sessions do
      before(:create) do |event|
        event.event_sessions.destroy_all
      end
    end
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:address) { |n| "#{n} Street San Francisco, CA 94108" }
  end
  
  factory :event_session do
    starts_at DateTime.now
    ends_at (DateTime.now + 1.day)
  end

  factory :role do
    sequence(:title) { "Teacher Level #{n}" }
  end

  factory :volunteer_rsvp do
    user 
    event
    attending true
  end
end