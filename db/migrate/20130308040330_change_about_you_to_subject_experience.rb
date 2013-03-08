class ChangeAboutYouToSubjectExperience < ActiveRecord::Migration
  def up
    change_column :rsvps, :about_you, :string, :limit => 250
    rename_column :rsvps, :about_you, :subject_experience
  end

  def down
    rename_column :rsvps, :subject_experience, :about_you
    change_column :rsvps, :about_you, :text
  end
end
