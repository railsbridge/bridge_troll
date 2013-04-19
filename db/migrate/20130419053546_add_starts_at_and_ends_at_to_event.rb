class AddStartsAtAndEndsAtToEvent < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    has_many :event_sessions, dependent: :destroy
  end

  def up
    add_column :events, :starts_at, :datetime
    add_column :events, :ends_at, :datetime

    Event.reset_column_information
    Event.find_each do |event|
      event.update_attribute :starts_at, event.event_sessions.minimum("event_sessions.starts_at")
      event.update_attribute :ends_at, event.event_sessions.maximum("event_sessions.ends_at")
    end
  end

  def down
    remove_column :events, :starts_at
    remove_column :events, :ends_at
  end
end
