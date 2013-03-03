Rails.application.config.middleware.use OmniAuth::Builder do
  provider :meetup, ENV['MEETUP_OAUTH_KEY'], ENV['MEETUP_OAUTH_SECRET']
end