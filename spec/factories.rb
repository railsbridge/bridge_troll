Factory.define :user do |f|
  f.sequence(:email) { |n| "example0#{n}@example.com"}
  f.password "test123"
end