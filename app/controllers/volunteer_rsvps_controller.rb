class VolunteerRsvpsController < ApplicationController

  before_filter :authenticate_user!

  def index; end

  def create
    #redirect_to "/events" and return if !user_signed_in?
    @rsvp = VolunteerRsvp.find_or_initialize_by_event_id_and_user_id(params[:event_id],current_user.id)
    @rsvp.attending = true
    if @rsvp.save
      redirect_to @rsvp.event, notice: 'Thanks for volunteering!'
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def update
    @rsvp = VolunteerRsvp.find(params[:id])
    redirect_to events_path, notice: 'You are not signed up to volunteer for this event' and return unless @rsvp.attending?

    @rsvp.attending = false
    if @rsvp.save
      redirect_to events_path, notice: 'Sorry to hear you can not volunteer. We hope you can make it to our next event!'
    else
      redirect_to events_path, error: 'There was a problem updating your rsvp, please try again.'
    end
  end

end