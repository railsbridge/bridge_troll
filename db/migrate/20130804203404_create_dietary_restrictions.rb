class CreateDietaryRestrictions < ActiveRecord::Migration
  def change
  	create_table :dietary_restrictions do |t|
  		t.string :restriction
  		t.references :rsvp

      t.timestamps
  	end
  end
end
