class Authentication < ActiveRecord::Base
  validates_uniqueness_of :provider, scope: [:uid]

  belongs_to :user, inverse_of: :authentications, counter_cache: true

  after_commit :authentication_created, on: :create

  def authentication_created
    OmniauthProviders.finish_auth_for(self)
  end
end
