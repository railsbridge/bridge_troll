class AddTimeZoneToEvents < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def change
    add_column :events, :time_zone, :string

    Event.find_each do |event|
      event.time_zone = "Pacific Time (US & Canada)"
      event.save!
    end
  end
end
