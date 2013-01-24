class AddAboutYouToVolunteerRsvps < ActiveRecord::Migration
  def change
    add_column :volunteer_rsvps, :about_you, :text
  end
end
