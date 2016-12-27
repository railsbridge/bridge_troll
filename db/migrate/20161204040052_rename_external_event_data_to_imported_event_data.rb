class RenameExternalEventDataToImportedEventData < ActiveRecord::Migration
  def change
    rename_column :events, :external_event_data, :imported_event_data
  end
end
