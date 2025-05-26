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

# this is copied from https://github.com/teamcapybara/capybara/blob/0480f90168a40780d1398c75031a255c1819dce8/lib/capybara/registrations/drivers.rb#L31-L42
# it's a modified version of the original chrome headless driver with a wider window.
# it resolves a flake in ./spec/features/admin/course_request_spec.rb:41 where the "Remove Level" button isn't clickable
# I don't understand why the flake exists though, because the screenshot of the page makes the button seem clickable...
Capybara.register_driver :selenium_chrome_headless_wide do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless=new')
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument('--disable-site-isolation-trials')
    opts.add_argument('--window-size=1920,1080') # Set the window size to 1080p
  end

  Capybara::Selenium::Driver.new(app, **{ :browser => :chrome, options_key => browser_options })
end

Capybara::Screenshot.register_driver(:selenium_chrome_headless_wide) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.javascript_driver = :selenium_chrome_headless_wide
# Capybara.javascript_driver = :selenium_chrome

Capybara.asset_host = "http://#{Rails.application.routes.default_url_options[:host]}"
Capybara.disable_animation = true

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

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
    WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true)
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
