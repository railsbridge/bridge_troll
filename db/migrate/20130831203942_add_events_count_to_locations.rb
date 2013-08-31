class AddEventsCountToLocations < ActiveRecord::Migration
  class Location < ActiveRecord::Base
    has_many :events
  end

  def self.up
    add_column :locations, :events_count, :integer, :default => 0

    Location.reset_column_information
    Location.find_each do |l|
      Location.update_counters l.id, :events_count => l.events.length
    end
  end

  def self.down
    remove_column :locations, :events_count
  end
end
