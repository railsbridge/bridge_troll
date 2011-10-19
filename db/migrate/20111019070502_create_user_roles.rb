class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.integer :user_id, :references => :users
      t.integer :role_id, :references => :roles
      t.timestamps
    end
  end

  def self.down
    drop_table :user_roles
  end
end
