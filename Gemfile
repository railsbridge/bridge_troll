source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.2'

gem 'dotenv-rails', groups: [:development, :test]

gem 'rails', '4.2.0'
gem 'devise', '~> 3.4.0'
gem 'thin'
gem 'jquery-rails'
gem 'nested_form'
gem 'select2-rails'
gem 'active_hash'
gem 'sanitize'
gem 'gmaps4rails'
gem 'geocoder'
gem 'omniauth-meetup'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'gravatar_image_tag'
gem 'simple_form'
gem 'rack-canonical-host'
gem 'icalendar'

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'heroku_rails_deflate'
  gem 'newrelic_rpm'
  gem 'sentry-raven'
end

gem 'handlebars_assets'
gem 'jquery-datatables-rails'
gem 'sass-rails'
gem 'compass-rails', github: 'compass/compass-rails' # awaiting compass-rails 2.0.2
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jquery-ui-rails'
gem 'backbone-on-rails'
gem 'masonry-rails'

group :development do
  gem 'quiet_assets'
  gem 'rb-fsevent'
  gem "bullet"
  gem "heroku_san"
  gem "better_errors"
  gem "binding_of_caller"
end

group :test, :development do
  gem 'jasmine'
  gem 'jasmine-jquery-rails'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'awesome_print'
  gem 'rails-assets-sinonjs'
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
end
