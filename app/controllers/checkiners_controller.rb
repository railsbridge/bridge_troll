class CheckinersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!

  def index
    @checkiner_rsvps = @event.attendee_rsvps.where(checkiner: true).includes(:user)
    @potential_checkiners = @event.attendee_rsvps.where(checkiner: false).includes(:user)
  end

  def create
    @rsvp  = @event.rsvps.find(params[:event_checkiner][:rsvp_id])
    @rsvp.update_attribute(:checkiner, true)
    redirect_to event_checkiners_path(@event), notice: "#{@rsvp.user.full_name} is now a checkiner for #{@event.title}!"
  end

  def destroy
    @rsvp = @event.rsvps.find(params[:id])
    @rsvp.update_attribute(:checkiner, false)
    redirect_to event_checkiners_path(@event), notice: "#{@rsvp.user.full_name} is no longer a checkiner for #{@event.title}!"
  end
end
