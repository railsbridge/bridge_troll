class Authentication < ActiveRecord::Base
  validates_uniqueness_of :provider, scope: [:uid]

  belongs_to :user, inverse_of: :authentications

  after_create :authentication_created

  def authentication_created
    OmniauthProviders.finish_auth_for(self)
  end
end
