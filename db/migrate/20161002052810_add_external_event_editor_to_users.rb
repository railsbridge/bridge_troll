# frozen_string_literal: true

class AddExternalEventEditorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :external_event_editor, :boolean, default: false
  end
end
