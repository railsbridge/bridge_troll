class AddExternalEventsCountToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :external_events_count, :integer, default: 0
  end
end
