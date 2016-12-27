class CheckinersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event

  def index
    authorize @event, :edit?
    render_index
  end

  def create
    authorize @event, :edit?
    @rsvp  = @event.rsvps.find_by(id: params.fetch(:event_checkiner, {})[:rsvp_id])
    unless @rsvp
      @event.errors.add(:base, 'Please select a user!')
      return render_index
    end

    @rsvp.update_attribute(:checkiner, true)
    redirect_to event_checkiners_path(@event), notice: "#{@rsvp.user.full_name} is now a checkiner for #{@event.title}!"
  end

  def destroy
    authorize @event, :edit?
    @rsvp = @event.rsvps.find(params[:id])
    @rsvp.update_attribute(:checkiner, false)
    redirect_to event_checkiners_path(@event), notice: "#{@rsvp.user.full_name} is no longer a checkiner for #{@event.title}!"
  end

  private

  def find_event
    @event ||= Event.find(params[:event_id])
  end

  def render_index
    @checkiner_rsvps = @event.attendee_rsvps.where(checkiner: true).includes(:user)
    @potential_checkiners = @event.attendee_rsvps.where(checkiner: false).includes(:user)
    render :index
  end
end
