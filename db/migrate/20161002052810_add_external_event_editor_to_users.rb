class AddExternalEventEditorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :external_event_editor, :boolean, default: false
  end
end
