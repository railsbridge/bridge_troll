class CreateEventEmails < ActiveRecord::Migration
  def change
    create_table :event_emails do |t|
      t.references :event
      t.references :sender

      t.string :subject
      t.string :body
      t.timestamps
    end
    add_index :event_emails, :event_id
  end
end
