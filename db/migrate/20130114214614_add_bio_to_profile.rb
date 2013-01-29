class AddBioToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :bio, :text
  end
end
