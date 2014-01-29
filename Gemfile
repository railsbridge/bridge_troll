source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.14'
gem 'devise', '~> 3.0.0'
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
gem 'rack-canonical-host'
gem 'icalendar'

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

group :assets do
  gem 'turbo-sprockets-rails3'
  gem 'handlebars_assets'
  gem 'jquery-datatables-rails'
  gem 'sass-rails'
  # sass_rails_patch allows 'css.scss.erb' to work.
  # delete this when upgrading to rails 4 (sass-rails 4.0.0 incorporates a similar fix)
  gem 'sass_rails_patch'
  gem 'compass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'bootstrap-sass-rails', '~> 2.3.0'
  gem 'font-awesome-rails'
  gem 'jquery-ui-rails'
  gem 'backbone-on-rails'
end

group :development do
  gem 'sextant'
  gem 'quiet_assets'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
  gem "bullet"
  gem "heroku_san"
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
  gem 'shoulda-matchers'
  gem "faker"
  gem 'capybara-screenshot'
end
