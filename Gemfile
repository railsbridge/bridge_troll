source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.13'
gem 'devise', '~> 2.2.3'
gem 'thin'
gem 'jquery-rails'
gem 'nested_form'
gem 'select2-rails'
gem 'active_hash'
gem 'sanitize'
gem 'gmaps4rails'
gem 'omniauth-meetup'
gem 'gravatar_image_tag'
gem 'simple_form'
gem 'sentry-raven'

group :production do
  gem 'pg'
end

group :assets do
  gem 'handlebars_assets'
  gem 'jquery-datatables-rails'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'modernizr_rails', :require => 'modernizr-rails'
  gem 'uglifier'
  gem 'bootstrap-sass-rails'
  gem 'jquery-ui-rails'
  gem 'backbone-on-rails'
end

group :development do
  gem 'sextant'
  gem 'quiet_assets'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
end

group :test, :development do
  gem 'jasmine'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'awesome_print'
end

group :test do
  gem 'webmock'
  gem "factory_girl_rails"
  gem 'capybara', '>= 2.0.1'
  gem "poltergeist"
  gem "launchy"
  gem "database_cleaner"
  gem 'shoulda-matchers'
  gem "faker"
  gem 'capybara-screenshot'
end
