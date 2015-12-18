class CacheEventRsvpCounts < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    has_many :rsvps, dependent: :destroy, inverse_of: :event
    has_many :student_rsvps, -> { where(role_id: Role::STUDENT.id, waitlist_position: nil) }, class_name: 'Rsvp', inverse_of: :event
    has_many :student_waitlist_rsvps, -> { where("role_id = #{Role::STUDENT.id} AND waitlist_position IS NOT NULL") }, class_name: 'Rsvp', inverse_of: :event
    has_many :volunteer_rsvps, -> { where(role_id: Role::VOLUNTEER.id) }, class_name: 'Rsvp', inverse_of: :event
  end

  class Rsvp < ActiveRecord::Base
    belongs_to :event
  end

  def up
    add_column :events, :student_rsvps_count, :integer, default: 0
    add_column :events, :student_waitlist_rsvps_count, :integer, default: 0
    add_column :events, :volunteer_rsvps_count, :integer, default: 0

    Event.reset_column_information

    Event.all.each do |e|
      Event.update_counters e.id, student_rsvps_count: e.student_rsvps.count
      Event.update_counters e.id, student_waitlist_rsvps_count: e.student_waitlist_rsvps.count
      Event.update_counters e.id, volunteer_rsvps_count: e.volunteer_rsvps.count
    end
  end

  def down
    remove_column :events, :student_rsvps_count
    remove_column :events, :student_waitlist_rsvps_count
    remove_column :events, :volunteer_rsvps_count
  end
end
