class RenameExternalEventDataToImportedEventData < ActiveRecord::Migration[4.2]
  def change
    rename_column :events, :external_event_data, :imported_event_data
  end
end
