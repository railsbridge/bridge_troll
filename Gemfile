# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.1'

gem 'active_hash'
# OPTIMIZE: and cache expensive computations for faster boot times. It's
# `require`d in a specific way in config/boot.rb
gem 'backbone-on-rails'
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
gem 'rails', '~> 5.2.4.3'
gem 'sanitize'
gem 'sassc-rails'
gem 'simple_form'
gem 'sprockets'
gem 'uglifier'
# faster interoperable json
gem 'multi_json'
gem 'oj'

group :production do
  gem 'newrelic_rpm'
  gem 'pg'
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
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'parallel_tests'
  gem 'pry'
  gem 'rails-controller-testing', require: false
  gem 'rake', require: false
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
  gem 'sqlite3'
end

if ENV['FORCE_POSTGRES']
  group :development, :test do
    gem 'pg' # rubocop:disable Bundler/DuplicatedGem
  end
end

group :test do
  gem 'apparition'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end
