# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  after_initialize :remove_at_from_twitter_username

  validates :github_username, format: { with: /\A([a-z0-9-]+-)*[a-z0-9]+\Z/i, allow_blank: true }
  validates :twitter_username, format: { with: /\A@?\w{1,15}\Z/i, allow_blank: true }

  validates :user_id, uniqueness: true

  def remove_at_from_twitter_username
    self.twitter_username = twitter_username.try(:gsub, /\A@*/, '')
  end
end
