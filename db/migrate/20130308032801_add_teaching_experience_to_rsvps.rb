class AddTeachingExperienceToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :teaching_experience, :string, :limit => 250
  end
end
