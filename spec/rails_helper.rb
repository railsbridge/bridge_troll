ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'webmock/rspec'

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = "http://#{Rails.application.routes.default_url_options[:host]}"

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.use_transactional_fixtures = true

  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
    Time.zone = 'UTC'
  end

  config.include Devise::TestHelpers, type: :controller
  config.include SignInHelper, type: :feature
  config.include EventFormHelper, type: :feature

  config.include FactoryGirl::Syntax::Methods

  [:feature, :request].each do |type|
    config.include Warden::Test::Helpers, type: type
    config.after(:example, type: type) do
      Warden.test_reset!
    end
  end
end
