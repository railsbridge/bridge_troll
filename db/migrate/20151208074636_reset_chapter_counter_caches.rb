class ResetChapterCounterCaches < ActiveRecord::Migration
  def change
    Chapter.all.each do |chapter|
      Chapter.reset_counters(chapter.id, :events, :external_events)
    end
  end
end
