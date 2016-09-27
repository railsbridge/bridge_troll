class AddEmailAuthenticationTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_authentication_token, :string
    add_column :users, :email_authentication_created_at, :timestamp

    add_index :users, :email_authentication_token, unique: true
  end
end
