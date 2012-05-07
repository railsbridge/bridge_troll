FactoryGirl.define do
  factory :user do
    name "Anne"
    sequence(:email) { |n| "example0#{n}@example.com"}
    confirmed_at DateTime.now # all users are confirmed by default
    password "test123"
  end

  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    date DateTime.now 
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:address) { |n| "#{n} Street San Francisco, CA 94108" }
  end
end