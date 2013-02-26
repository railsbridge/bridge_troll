class AddUserTypeToRsvps < ActiveRecord::Migration
  class Rsvp < ActiveRecord::Base; end

  def up
    add_column :rsvps, :user_type, :string
    Rsvp.find_each do |rsvp|
      rsvp.update_attribute(:user_type, 'User')
    end
  end

  def down
    remove_column :rsvps, :user_type
  end
end
