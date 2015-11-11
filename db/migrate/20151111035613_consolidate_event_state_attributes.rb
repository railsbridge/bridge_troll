class ConsolidateEventStateAttributes < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    enum current_state: [ :draft, :pending_approval, :published ]
  end

  def up
    add_column :events, :current_state, :integer, default: 0

    Event.find_each do |event|
      state = if event.attributes['published']
                :published
              elsif event.attributes['draft_saved']
                :draft
              else
                :pending_approval
              end
      event.update_attributes(current_state: state)
    end

    remove_column :events, :published
    remove_column :events, :draft_saved
  end

  def down
    add_column :events, :published, :boolean, default: false
    add_column :events, :draft_saved, :boolean, default: false

    Event.find_each do |event|
      if event.published?
        event.update_attributes(published: true, draft_saved: false)
      elsif event.draft?
        event.update_attributes(published: false, draft_saved: true)
      end
    end

    remove_column :events, :current_state
  end
end
