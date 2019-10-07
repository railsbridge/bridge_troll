class Profile < ActiveRecord::Base
  belongs_to :user, inverse_of: :profile, required: true

  after_initialize :remove_at_from_twitter_username

  validates_format_of :github_username, with: /\A([a-z0-9-]+-)*[a-z0-9]+\Z/i, allow_blank: true
  validates_format_of :twitter_username, with: /\A@?\w{1,15}\Z/i, allow_blank: true

  validates_uniqueness_of :user_id

  def remove_at_from_twitter_username
    self.twitter_username = twitter_username.try(:gsub, /\A@*/, '')
  end
end
