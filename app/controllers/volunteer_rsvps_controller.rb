class VolunteerRsvpsController < ApplicationController
  before_filter :authenticate_user!

  def new
    flash[:notice] = "AWESOME - you're almost signed up"
    @event = Event.find(params[:event_id])
    @rsvp = @event.volunteer_rsvps.build

    if old_rsvp = VolunteerRsvp.find_by_user_id_and_event_id(current_user.id, params[:event_id])
      redirect_to edit_volunteer_rsvp_path(old_rsvp) and return
    end
  end

  def create
    @rsvp = VolunteerRsvp.new(params[:volunteer_rsvp])
    @rsvp.event = Event.find(params[:volunteer_rsvp][:event_id])
    @rsvp.user = current_user
    @rsvp.attending = true
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
    @rsvp = VolunteerRsvp.find(params[:id])
    if @rsvp.update_attributes(params[:volunteer_rsvp].merge(:attending => true))
      redirect_to event_path(@rsvp.event_id)
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def destroy
    @rsvp = VolunteerRsvp.find_by_id(params[:id])
    redirect_to events_path, notice: 'You are not signed up to volunteer for this event' and return unless @rsvp

    event = @rsvp.event
    @rsvp.destroy
    redirect_to events_path, notice: "You are now no longer signed up to volunteer for #{event.title}"
  end
end