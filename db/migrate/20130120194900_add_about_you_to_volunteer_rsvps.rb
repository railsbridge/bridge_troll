class AddAboutYouToVolunteerRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :about_you, :text
  end
end
