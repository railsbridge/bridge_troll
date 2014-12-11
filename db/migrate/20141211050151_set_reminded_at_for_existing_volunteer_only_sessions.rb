class SetRemindedAtForExistingVolunteerOnlySessions < ActiveRecord::Migration
  class EventSession < ActiveRecord::Base; end
  class RsvpSession < ActiveRecord::Base
    belongs_to :event_session
  end

  def up
    RsvpSession.joins(:event_session).where('event_sessions.volunteers_only = ?', true).find_each do |rsvp_session|
      rsvp_session.update_attributes(reminded_at: Time.now)
    end
  end
end
