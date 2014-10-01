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

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.use_transactional_fixtures = true

  config.before(:each) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  config.include Devise::TestHelpers, :type => :controller

  config.include FactoryGirl::Syntax::Methods

  [:feature, :request].each do |type|
    config.include Warden::Test::Helpers, type: type
  end

  config.before do |example|
    Warden.test_mode! if example.metadata[:js]
  end

  config.after do |example|
    Warden.test_reset! if example.metadata[:js]
  end
end
