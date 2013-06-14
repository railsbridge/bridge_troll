class Events::AttendeesController < ApplicationController
  before_filter :authenticate_user!, :validate_organizer!, :find_event

  def index
    @rsvps = @event.attendee_rsvps
  end

  def update
    @rsvp = @event.rsvps.find(params[:id])
    @rsvp.section_id = params[:attendee][:section_id]
    if @rsvp.save
      render json: @rsvp
    else
      render json: @rsvp, status: :unprocessable_entity
    end
  end

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end
end
