class AddNameAndAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string, :null => false, :after => :email
    add_column :users, :admin, :boolean, :default => false, :after => :name
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :admin
  end
end
