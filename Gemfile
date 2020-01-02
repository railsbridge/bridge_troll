# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.5'

gem 'dotenv-rails', groups: %i[development test]

gem 'active_hash'
gem 'devise'
gem 'geocoder'
gem 'gmaps4rails'
gem 'gravatar_image_tag'
gem 'icalendar'
gem 'jquery-rails'
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
gem 'rack-mini-profiler', require: false
gem 'rails', '~> 5.2.4.1'
gem 'sanitize'
gem 'simple_form'
# faster interoperable json
gem 'multi_json'
gem 'oj'

# OPTIMIZE: and cache expensive computations for faster boot times. It's
# `require`d in a specific way in config/boot.rb
gem 'bootsnap', require: false

group :production do
  gem 'newrelic_rpm'
  gem 'pg'
  gem 'rack-timeout'
  gem 'sentry-raven'
end

if ENV['FORCE_POSTGRES']
  group :development, :test do
    gem 'pg' # rubocop:disable Bundler/DuplicatedGem
  end
end

gem 'backbone-on-rails'
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'font-awesome-rails'
gem 'handlebars_assets'
gem 'jquery-ui-rails'
gem 'sassc-rails'
gem 'sprockets', '~> 4.0.0' # sprockets 4 requires some more major changes
gem 'uglifier'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'listen'
  gem 'rb-fsevent'
  gem 'spring'
  gem 'spring-commands-rspec', group: :development
end

group :test, :development do
  gem 'awesome_print'
  gem 'byebug'
  gem 'chrome_remote'
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
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
  gem 'sqlite3'
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
