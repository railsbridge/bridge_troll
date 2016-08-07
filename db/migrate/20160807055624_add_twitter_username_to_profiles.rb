class AddTwitterUsernameToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :twitter_username, :string
  end
end
