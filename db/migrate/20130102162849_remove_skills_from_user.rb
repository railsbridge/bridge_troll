class RemoveSkillsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :childcaring
    remove_column :users, :coordinating
    remove_column :users, :designing
    remove_column :users, :evangelizing
    remove_column :users, :hacking
    remove_column :users, :linux
    remove_column :users, :macosx
    remove_column :users, :mentoring
    remove_column :users, :other
    remove_column :users, :taing
    remove_column :users, :teaching
    remove_column :users, :user_id
    remove_column :users, :windows
    remove_column :users, :writing
  end
end
