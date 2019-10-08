ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'rails-controller-testing'
# Add additional requires below this line. Rails is not loaded until this point!

require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'webmock/rspec'
require 'selenium-webdriver'

if ENV['JS_DRIVER'] == 'selenium' || ENV['SELENIUM'].present?
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: ENV.fetch('BROWSER', 'chrome').to_sym)
  end
  Capybara.javascript_driver = :selenium
else
  # need to fix window size else tests aren't consistent
  window_size = "window-size=1024,768"
  # installs latest chromedriver

  Capybara.register_driver :selenium_chrome_headless_with_resolution_for_travis do |app|

    browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
      opts.args << '--headless'
      opts.args << '--disable-gpu' if Gem.win_platform?
      # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
      opts.args << '--disable-site-isolation-trials'
      opts.args << "--#{window_size}"
      opts.args << "--no-sandbox" # see https://docs.travis-ci.com/user/chrome#sandboxing, https://docs.travis-ci.com/user/chrome#capybara
    end

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.register_driver :selenium_chrome_with_resolution do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
      # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
      opts.args << '--disable-site-isolation-trials'
      opts.args << "--#{window_size}"
    end

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Selenium::WebDriver::Chrome::Service.driver_path = Rails.root.join("node_modules", ".bin", "chromedriver").to_s
  Capybara.javascript_driver = :selenium_chrome_headless_with_resolution_for_travis
  # Capybara.javascript_driver = :selenium_chrome_with_resolution
end

Capybara.asset_host = "http://#{Rails.application.routes.default_url_options[:host]}"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].each {|f| require f}

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

  config.before(:each) do |example|
    WebMock.disable_net_connect!(allow_localhost: true)
    Time.zone = 'UTC'
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include SignInHelper, type: :feature
  config.include EventFormHelper, type: :feature
  config.include FormHelper, type: :feature

  config.include FactoryBot::Syntax::Methods

  [:feature, :request].each do |type|
    config.include Warden::Test::Helpers, type: type
    config.after(:example, type: type) do
      Warden.test_reset!
    end
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
