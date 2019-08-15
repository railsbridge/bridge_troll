require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module Bridgetroll
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # set default from address across
    ActionMailer::Base.default from: 'Bridge Troll <troll@railsbridge.org>'

    # Devise emails use our layout
    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    # allow cross origin requests from BridgeFoundry
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'bridgefoundry.org'
        resource '/events.json', headers: :any, methods: [:get]
      end
    end

    # taken from https://github.com/tylerhunt/rack-canonical-host/issues/36#issuecomment-330813507
    # to support HSTS, we want to redirect to SSL before redirecting to www

    config.middleware.insert_after(
      ActionDispatch::SSL,
      Rack::CanonicalHost, ENV['CANONICAL_HOST']
    )
  end
end
