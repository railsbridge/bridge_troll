class AddSkillsToUsers < ActiveRecord::Migration
  def change
     add_column :users, :teaching, :boolean
     add_column :users, :taing, :boolean
     add_column :users, :coordinating, :boolean
     add_column :users, :childcaring, :boolean
     add_column :users, :writing, :boolean
     add_column :users, :hacking, :boolean
     add_column :users, :designing, :boolean
     add_column :users, :evangelizing, :boolean
     add_column :users, :mentoring, :boolean
     add_column :users, :macosx, :boolean
     add_column :users, :windows, :boolean
     add_column :users, :linux, :boolean     
     add_column :users, :other, :string
  end
end
