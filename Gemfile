# frozen_string_literal: true

source 'https://rubygems.org'

# these two gems are installed by default in ruby <= 3.4 but will be removed in ruby 3.5
# When upgrading rails, test if explicitly installing these gems is still necessary
gem 'benchmark'
gem 'reline'

gem 'active_hash'
gem 'rake', require: false
# OPTIMIZE: and cache expensive computations for faster boot times. It's
# `require`d in a specific way in config/boot.rb
gem 'bootsnap', require: false
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'devise'
gem 'font-awesome-rails'
gem 'geocoder'
gem 'gmaps4rails'
gem 'handlebars_assets'
gem 'icalendar'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'nearest_time_zone'
gem 'nested_form'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-twitter'
gem 'puma'
gem 'pundit'
gem 'rack-canonical-host'
gem 'rack-cors'
gem 'rack-mini-profiler', require: ['prepend_net_http_patch']
gem 'rails', '~> 8.0.0'
gem 'rails-backbone'
gem 'sanitize'
gem 'sassc-rails'
gem 'simple_form'
gem 'sprockets'
gem 'uglifier'
# faster interoperable json
gem 'ffi'
gem 'multi_json'
gem 'oj'
gem 'pg'

group :production do
  gem 'newrelic_rpm'
  gem 'rack-timeout'
  gem 'sentry-raven'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'listen'
  gem 'rb-fsevent'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test, :development do
  gem 'awesome_print'
  gem 'byebug'
  gem 'chrome_remote', require: false
  gem 'dotenv-rails'
  gem 'parallel_tests'
  gem 'pry'
  gem 'rails-controller-testing', require: false
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
  # in production, we use postgres. For a simpler dev experience you can also use sqlite3
  gem 'sqlite3'
end

group :test do
  # these two gems are installed by default in ruby <= 3.3 but removed in ruby 3.4
  # they are used by rails 6's test infrastructure. Perhaps they are no longer necessary in later versions of rails
  gem 'drb'
  gem 'mutex_m'

  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end
