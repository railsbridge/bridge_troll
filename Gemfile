source 'http://rubygems.org'

gem 'rails', '3.2.9'
gem 'devise', '2.0.4' # later versions use a different migration DSL and schema
gem 'pg'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails'
  gem 'bootstrap-sass'
  gem 'therubyracer'
end

gem 'jquery-rails'

group :test do
  gem "factory_girl_rails"
  gem 'capybara'
  gem 'poltergeist'
  gem "guard-rspec"
  gem "launchy"
  gem "database_cleaner"
  gem 'simplecov', :require => false
end

group :test, :development do
  gem 'sqlite3'
  gem 'annotate', '~> 2.4.1.beta'
  gem 'rspec-rails'
end

