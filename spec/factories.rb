FactoryGirl.define do
  factory :user do
    first_name "Anne"
    last_name "Hall"
    sequence(:email) { |n| "example0#{n}@example.com"}
    confirmed_at DateTime.now # all users are confirmed by default
    password "test123"
  end

  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    date 1.year.from_now
    details "This is note in the details attribute."
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:address) { |n| "#{n} Street San Francisco, CA 94108" }
  end
end