class AddSpammerFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :spammer, :boolean, default: false
  end
end
