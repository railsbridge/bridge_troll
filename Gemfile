source 'https://rubygems.org'

ruby '2.5.3'

gem 'dotenv-rails', groups: [:development, :test]

gem 'rails', '~> 5.0.7'
gem 'devise', '~> 4.6.0'
gem 'pundit'
gem 'puma'
gem 'jquery-rails'
gem 'nested_form'
gem 'active_hash'
gem 'sanitize'
gem 'gmaps4rails'
gem 'geocoder'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'gravatar_image_tag'
gem 'simple_form'
gem 'rack-canonical-host'
gem 'icalendar'
gem 'rack-mini-profiler'
gem 'bower-rails'
gem 'nearest_time_zone'
gem 'rack-cors'

group :production do
  gem 'pg'
  gem 'newrelic_rpm'
  gem 'sentry-raven'
  gem 'rack-timeout'
end

if ENV['FORCE_POSTGRES']
  group :development, :test do
    gem 'pg'
  end
end

gem 'handlebars_assets'
gem 'sassc-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jquery-ui-rails'
gem 'backbone-on-rails'

group :development do
  gem 'rb-fsevent'
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'listen'
end

group :test, :development do
  gem 'jasmine', '~> 2.6.0'
  gem 'jasmine-jquery-rails'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'awesome_print'
  gem 'rails-controller-testing', require: false
end

group :test do
  gem 'webmock'
  gem 'factory_bot_rails', '4.8.2'
  gem 'capybara', '2.13.0'
  gem 'poltergeist', require: false
  gem 'selenium-webdriver', require: false
  gem 'launchy'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'
  gem 'faker'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'simplecov', '0.16.1', require: false
end
