module EventsHelper
  def check_volunteer_status (event_id)
    @rsvp = VolunteerRsvp.where(:user_id => current_user, :event_id => event_id).first
    return @rsvp.nil?
  end
end
