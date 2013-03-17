class AddTimeZoneToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def up
    add_column :users, :time_zone, :string
    User.find_each do |user|
      user.time_zone = "Pacific Time (US & Canada)"
      user.save!
    end
  end

  def down
    remove_column :users, :time_zone
  end
end
