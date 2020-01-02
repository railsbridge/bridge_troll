# frozen_string_literal: true

if defined?(Raven)
  Raven.configure do |config|
    config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT + ['ActionController::UnknownFormat']
  end
end
