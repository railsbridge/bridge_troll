class CreateEventEmailRecipients < ActiveRecord::Migration
  def change
    create_table :event_email_recipients do |t|
      t.references :event_email
      t.references :recipient_rsvp

      t.timestamps
    end
    add_index :event_email_recipients, :event_email_id
    add_index :event_email_recipients, :recipient_rsvp_id
  end
end
