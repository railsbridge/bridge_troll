class EventsController < ApplicationController
  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = "Event successfully saved!"
      redirect_to event_path @event
    else
      redirect_to new_event_path
    end
  end

  def show
    @event = Event.find(params[:id], :include => [:registrations, :location])
    @volunteering = Volunteering.new(:event => @event, :user => current_user)
  end
end
