Factory.define :user do |f|
  f.sequence(:email) { |n| "example0#{n}@example.com"}
  f.confirmed_at DateTime.now # all users are confirmed by default
  f.password "test123"
end

Factory.define :event do |e|
  e.sequence(:title) { |n| "Event #{n}" }
end
