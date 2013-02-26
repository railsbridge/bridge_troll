class CreateMeetupUsers < ActiveRecord::Migration
  def change
    create_table :meetup_users do |t|
      t.string :full_name
      t.integer :meetup_id

      t.timestamps
    end
  end
end
