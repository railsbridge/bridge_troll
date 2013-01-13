FactoryGirl.define do
  factory :user do
    first_name "Anne"
    last_name "Hall"
    sequence(:email) { |n| "example0#{n}@example.com"}
    confirmed_at DateTime.now
    password "test123"
  end

  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    details "This is note in the details attribute."

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
end