class AddTwitterUsernameToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :twitter_username, :string
  end
end
