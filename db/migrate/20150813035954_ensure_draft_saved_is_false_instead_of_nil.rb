class EnsureDraftSavedIsFalseInsteadOfNil < ActiveRecord::Migration
  class Event < ActiveRecord::Base; end

  def up
    change_column_default :events, :draft_saved, false
    Event.find_each do |e|
      e.update_attribute(:draft_saved, false) if e.draft_saved.nil?
    end
  end

  def down
    change_column_default :events, :draft_saved, nil
  end
end
