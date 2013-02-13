source 'http://rubygems.org'

gem 'rails', '3.2.11'
gem 'devise', '2.1.2'
gem 'thin'
gem 'jquery-rails'
gem 'nested_form'
gem 'select2-rails'
gem 'active_hash'

group :production do
  gem 'pg'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'modernizr_rails', :require => 'modernizr-rails'
  gem 'uglifier'
  gem 'bootstrap-sass-rails'
  gem 'jquery-ui-rails'
end

group :development do
  gem 'quiet_assets'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
end

group :test, :development do
  gem 'sqlite3'
  gem 'rspec-rails'
end

group :test do
  gem "factory_girl_rails"
  gem 'capybara'
  gem "poltergeist"
  gem "launchy"
  gem "database_cleaner"
  gem 'shoulda-matchers'
  gem "faker"
end