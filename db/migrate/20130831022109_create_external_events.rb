class CreateExternalEvents < ActiveRecord::Migration
  def change
    create_table :external_events do |t|
      t.string :name
      t.string :url
      t.date :starts_at
      t.date :ends_at
      t.string :city
      t.string :location
      t.string :organizers

      t.timestamps
    end
  end
end
