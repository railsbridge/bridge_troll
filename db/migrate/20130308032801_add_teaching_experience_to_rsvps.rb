class AddTeachingExperienceToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :experience, :string, :limit => 250
  end
end
