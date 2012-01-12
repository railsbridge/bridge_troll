source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'sass', '~> 3.1.0.alpha.252'

gem 'devise'
gem 'haml'
gem 'cancan'

#Gem used only for assets and not required in production environment by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

group :development do
  gem 'mongrel', '>= 1.2.0.pre2'
end

group :development, :test do
  gem 'heroku'
  gem 'sqlite3'
  gem 'rspec'
  gem 'rspec-rails', '~> 2.8.1'
  gem 'ruby-debug19'

  gem 'capybara'
  gem 'selenium-client'

  gem 'faker'
  gem 'factory_girl_rails'
end

group :production do
  gem 'pg'
end
	
