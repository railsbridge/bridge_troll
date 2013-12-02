class VolunteersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_event
  before_filter :validate_organizer!

  def index
    @volunteer_rsvps = @event.volunteer_rsvps
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
