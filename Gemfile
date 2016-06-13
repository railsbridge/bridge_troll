source 'https://rubygems.org'

ruby '2.3.1'

gem 'dotenv-rails', groups: [:development, :test]

gem 'rails', '4.2.6'
gem 'devise', '~> 4.1.0'
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
gem 'pg' if ENV['FORCE_POSTGRES']
gem 'rack-mini-profiler'
gem 'bower-rails'

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'heroku_rails_deflate'
  gem 'newrelic_rpm'
  gem 'sentry-raven'
  gem 'rack-timeout'
end

gem 'handlebars_assets'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jquery-ui-rails'
gem 'backbone-on-rails'

group :development do
  gem 'quiet_assets'
  gem 'rb-fsevent'
  gem "bullet"
  gem "heroku_san"
  gem "better_errors"
  gem "binding_of_caller"
  gem "byebug"
end

group :test, :development do
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'awesome_print'
end

group :test do
  gem 'webmock'
  gem "factory_girl_rails"
  gem 'capybara', '>= 2.0.1'
  gem "poltergeist"
  gem "launchy"
  gem 'shoulda-matchers'
  gem "faker"
  gem 'capybara-screenshot'
  # Remove after Rails 5: https://github.com/rails/rails/pull/18458
  gem 'test_after_commit'
end
