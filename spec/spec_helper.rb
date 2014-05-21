ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'webmock/rspec'

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'

Rails.application.routes.default_url_options[:host] = 'localhost:3000'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  config.use_transactional_fixtures = true

  config.before(:each) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  config.include Devise::TestHelpers, :type => :controller

  config.include FactoryGirl::Syntax::Methods

  # Monkey-patch to force single DB connection even in multithreaded
  #   tests (selenium/capybara-webkit/poltergeist)
  ActiveRecord::ConnectionAdapters::ConnectionPool.class_eval do
    def current_connection_id
      Thread.main.object_id
    end
  end

  [:feature, :request].each do |type|
    config.include Warden::Test::Helpers, type: type
  end

  config.before do
    Warden.test_mode! if example.metadata[:js]
  end

  config.after do
    Warden.test_reset! if example.metadata[:js]
  end
end
