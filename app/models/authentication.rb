class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id
  validates_uniqueness_of :provider, scope: [:uid]

  belongs_to :user, inverse_of: :authentications
end
