class EventsController < ApplicationController
  def show
    @event = Event.find(params[:id], :include => [:registrations, :location])
  end
end
