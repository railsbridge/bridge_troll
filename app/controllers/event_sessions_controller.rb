class EventSessionsController < ApplicationController
  before_filter :authenticate_user!, :find_event, :validate_checkiner!

  def index
    @checkin_counts = @event.checkin_counts
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
