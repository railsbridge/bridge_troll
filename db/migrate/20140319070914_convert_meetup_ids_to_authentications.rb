class ConvertMeetupIdsToAuthentications < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_many :authentications, inverse_of: :user, dependent: :destroy
  end

  class Authentication < ActiveRecord::Base
    attr_accessible :provider, :uid, :user_id
    validates_uniqueness_of :provider, scope: [:uid]

    belongs_to :user, inverse_of: :authentications
  end

  def up
    User.find_each do |u|
      if u.meetup_id
        u.authentications.create!(provider: 'meetup', uid: u.meetup_id.to_s)
      end
    end
    remove_column :users, :meetup_id
  end

  def down
    add_column :users, :meetup_id, :integer
    User.find_each do |u|
      meetup_auth = u.authentications.find { |a| a.provider == 'meetup' }
      if meetup_auth
        u.update_attribute(:meetup_id, meetup_auth.uid.to_i)
        meetup_auth.destroy
      end
    end
  end
end
