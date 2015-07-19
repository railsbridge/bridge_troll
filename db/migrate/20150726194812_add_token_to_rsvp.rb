class AddTokenToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :token, :string

    add_index :rsvps, :token, unique: true
  end
end
