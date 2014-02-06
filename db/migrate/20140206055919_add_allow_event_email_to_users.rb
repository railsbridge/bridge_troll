class AddAllowEventEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_event_email, :boolean, default: true
  end
end
