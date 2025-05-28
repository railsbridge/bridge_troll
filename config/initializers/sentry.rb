# frozen_string_literal: true

if Rails.env.production?
  Sentry.init do |config|
    # get breadcrumbs from logs
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    # Add data like request headers and IP for users, if applicable;
    # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
    config.send_default_pii = true
  end
end
