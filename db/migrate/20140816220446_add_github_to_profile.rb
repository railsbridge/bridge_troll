class AddGithubToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :github, :string
  end
end
