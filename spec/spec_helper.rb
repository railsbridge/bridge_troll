# configuring code coverage
require 'simplecov'
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  #Uncomment if need to write tests using devise helpers
  #config.include Devise::TestHelpers, :type => :controller
  #config.extend ControllerMacros, :type => :controller

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.mock_with :rspec
  #config.use_transactional_fixtures = true

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::TestHelpers, :type => :controller
  
  config.include FactoryGirl::Syntax::Methods #added per FactoryGirl docs 
  # https://github.com/thoughtbot/factory_girl/wiki/Usage
end

