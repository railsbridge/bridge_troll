class VolunteerRsvpsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @rsvp = VolunteerRsvp.find_or_initialize_by_event_id_and_user_id(params[:event_id],current_user.id)
    @rsvp.attending = true
    if @rsvp.save
      redirect_to @rsvp.event, notice: 'Thanks for volunteering!'
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