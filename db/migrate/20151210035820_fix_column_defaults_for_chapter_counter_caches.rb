class FixColumnDefaultsForChapterCounterCaches < ActiveRecord::Migration
  def change
    change_column_default(:chapters, :events_count, 0)
    change_column_default(:chapters, :external_events_count, 0)
  end
end
