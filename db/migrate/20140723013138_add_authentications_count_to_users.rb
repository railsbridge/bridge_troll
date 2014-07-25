class AddAuthenticationsCountToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_many :authentications
  end
  class Authentication < ActiveRecord::Base
    belongs_to :user, counter_cache: true
  end

  def up
    add_column :users, :authentications_count, :integer

    User.reset_column_information
    User.select(:id).find_each do |u|
      User.reset_counters u.id, :authentications
    end
  end

  def down
    remove_column :users, :authentications_count
  end
end
