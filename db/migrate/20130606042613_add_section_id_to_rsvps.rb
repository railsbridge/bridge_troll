class AddSectionIdToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :section_id, :integer
  end
end
