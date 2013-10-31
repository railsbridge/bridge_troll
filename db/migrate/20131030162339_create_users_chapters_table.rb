class CreateUsersChaptersTable < ActiveRecord::Migration
  def up
    create_table :chapters_users, :id => false do |t|
      t.references :chapter
      t.references :user
    end
  end

  def down
    drop_table :chapters_users
  end
end
