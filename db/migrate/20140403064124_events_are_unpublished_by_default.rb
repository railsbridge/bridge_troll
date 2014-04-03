class EventsAreUnpublishedByDefault < ActiveRecord::Migration
  def up
    change_column_default :events, :published, false
  end

  def down
    change_column_default :events, :published, true
  end
end
