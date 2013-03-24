class AddChildcareInfoToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :childcare_info, :text
  end
end
