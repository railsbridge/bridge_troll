source 'https://rubygems.org'

ruby '2.6.5'

gem 'dotenv-rails', groups: [:development, :test]

gem 'rails', '~> 5.2.4.1'
gem 'devise'
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
gem 'omniauth-rails_csrf_protection'
gem 'gravatar_image_tag'
gem 'simple_form'
gem 'rack-canonical-host'
gem 'icalendar'
gem 'rack-mini-profiler', require: false
gem 'nearest_time_zone'
gem 'rack-cors'
# faster interoperable json
gem 'oj'
gem 'multi_json'

# optimize and cache expensive computations for faster boot times. It's
# `require`d in a specific way in config/boot.rb
gem 'bootsnap', require: false

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
gem 'sprockets', '~> 4.0.0' # sprockets 4 requires some more major changes

group :development do
  gem 'rb-fsevent'
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec', group: :development
end

group :test, :development do
  gem 'parallel_tests'
  gem 'byebug'
  gem 'awesome_print'
  gem 'chrome_remote'
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'pry'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'sqlite3'
  gem 'rails-controller-testing', require: false
  gem 'rake', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end
