# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'rails-controller-testing'
# Add additional requires below this line. Rails is not loaded until this point!

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'webmock/rspec'
require 'capybara/apparition'


Capybara.register_driver :apparition_visible do |app|
  Capybara::Apparition::Driver.new(app, headless: false)
end

# Capybara.javascript_driver = :apparition_visible
Capybara.javascript_driver = :apparition

Capybara.asset_host = "http://#{Rails.application.routes.default_url_options[:host]}"
Capybara.disable_animation = true

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Rails::Controller::Testing::TestProcess
  config.include Rails::Controller::Testing::TemplateAssertions
  config.include Rails::Controller::Testing::Integration

  config.infer_spec_type_from_file_location!

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    WebMock.disable_net_connect!(allow_localhost: true)
    Time.zone = 'UTC'
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include SignInHelper, type: :feature
  config.include EventFormHelper, type: :feature
  config.include FormHelper, type: :feature

  config.include FactoryBot::Syntax::Methods

  %i[feature request].each do |type|
    config.include Warden::Test::Helpers, type: type
    config.after(:example, type: type) do
      Warden.test_reset!
    end
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
