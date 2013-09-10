class ChangeEventEmailBodyToText < ActiveRecord::Migration
  def up
    change_column :event_emails, :body, :text, limit: nil
  end

  def down
    change_column :event_emails, :body, :string
  end
end
