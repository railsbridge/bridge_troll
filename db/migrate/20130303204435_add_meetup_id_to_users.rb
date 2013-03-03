class AddMeetupIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :meetup_id, :integer
  end
end
