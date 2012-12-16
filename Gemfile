source 'http://rubygems.org'

gem 'rails', '3.2.8'
gem 'devise', '2.0.4' # later versions use a different migration DSL and schema

group :production do
  gem 'pg'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'bootstrap-sass-rails'
end

gem 'jquery-rails'

group :test do
  gem "factory_girl_rails"
  gem 'capybara'
  gem "poltergeist"
  gem "launchy"
  gem "database_cleaner"
  gem 'simplecov', :require => false
end

group :test, :development do
  gem 'sqlite3'
  gem 'rspec-rails'
end
