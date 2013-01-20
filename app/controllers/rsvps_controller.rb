class RsvpsController < ApplicationController
  before_filter :authenticate_user!

  def new
    flash[:notice] = "AWESOME - you're almost signed up"
    @event = Event.find(params[:event_id])
    @rsvp = @event.rsvps.build
  end

  def create
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.event = Event.find(params[:rsvp][:event_id])
    @rsvp.user = current_user
    @rsvp.role_id = Role.id_for 'Volunteer'
    if @rsvp.save
      redirect_to @rsvp.event, notice: 'Thanks for volunteering!'
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def edit
  end

  def update
    @rsvp = Rsvp.find(params[:id])
    if @rsvp.update_attributes(params[:rsvp])
      redirect_to event_path(@rsvp.event_id)
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def destroy
    @rsvp = Rsvp.find_by_id(params[:id])
    redirect_to events_path, notice: 'You are not signed up to volunteer for this event' and return unless @rsvp

    event = @rsvp.event
    @rsvp.destroy
    redirect_to events_path, notice: "You are now no longer signed up to volunteer for #{event.title}"
  end
end