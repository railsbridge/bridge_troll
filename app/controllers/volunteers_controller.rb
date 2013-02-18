class VolunteersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_event
  before_filter :validate_organizer!

  def index
    @volunteer_rsvps = @event.volunteer_rsvps
  end

  def update
    rsvp = Rsvp.find(params[:id])
    rsvp.update_attribute(:volunteer_assignment_id, params[:volunteer_assignment_id])
    head :ok
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
