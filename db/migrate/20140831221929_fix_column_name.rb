class FixColumnName < ActiveRecord::Migration
  def change
  	rename_column :profiles, :github, :github_username
  end
end
