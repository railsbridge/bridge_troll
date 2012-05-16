class VolunteerRsvpsController < ApplicationController

  before_filter :authenticate_user!

  def create
    @vrsvp = VolunteerRsvp.find_or_initialize_by_event_id_and_user_id(params[:event_id],current_user.id)
    @vrsvp.attending = true
    if @vrsvp.save
      redirect_to root_path
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def update
    @vrsvp = VolunteerRsvp.find(params[:id])
    @vrsvp.attending = false
    if @vrsvp.save
      redirect_to root_path
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

end