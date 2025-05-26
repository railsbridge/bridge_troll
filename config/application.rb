# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bridgetroll
  class Application < Rails::Application
    def using_postgres?
      @using_postgres ||= (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL')
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # set default from address across
    ActionMailer::Base.default from: 'Bridge Troll <troll@railsbridge.org>'

    # Devise emails use our layout
    config.to_prepare do
      Devise::Mailer.layout 'mailer'
    end

    # allow cross origin requests from BridgeFoundry
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'bridgefoundry.org'
        resource '/events.json', headers: :any, methods: [:get]
      end
    end
  end
end
