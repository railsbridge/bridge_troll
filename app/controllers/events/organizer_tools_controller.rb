class Events::OrganizerToolsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def show
    @organizer_dashboard = true
    @volunteer_rsvps = @event.volunteer_rsvps
    @childcare_requests = @event.rsvps_with_childcare
    @checkin_counts = @event.checkin_counts
  end
end