class Events::AttendeesController < ApplicationController
  before_filter :authenticate_user!, :validate_organizer!, :find_event

  def index
    @rsvps = @event.student_rsvps + @event.volunteer_rsvps
  end

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end
end
