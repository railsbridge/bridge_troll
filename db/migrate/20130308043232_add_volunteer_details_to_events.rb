class AddVolunteerDetailsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :volunteer_details, :text
  end
end
