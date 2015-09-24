class VolunteersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event
  before_action :validate_organizer!

  def index
    @volunteer_rsvps = @event.volunteer_rsvps
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
