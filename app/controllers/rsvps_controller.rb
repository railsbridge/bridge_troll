class RsvpsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_rsvp, except: [:new, :create]

  def new
    flash[:notice] = "AWESOME - you're almost signed up"
    @event = Event.find(params[:event_id])
    @rsvp = @event.rsvps.build
  end

  def create
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.event = Event.find(params[:rsvp][:event_id])
    @rsvp.user = current_user

    @rsvp.role_id = Role::VOLUNTEER
    if @rsvp.save
      set_rsvp_sessions
      redirect_to @rsvp.event, notice: 'Thanks for volunteering!'
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def edit
  end

  def update
    if @rsvp.update_attributes(params[:rsvp])
      set_rsvp_sessions
      redirect_to event_path(@rsvp.event_id)
    else
      flash[:error] = 'There was an error saving your rsvp'
      redirect_to events_path
    end
  end

  def destroy
    event = @rsvp.event
    @rsvp.destroy
    redirect_to events_path, notice: "You are now no longer signed up to volunteer for #{event.title}"
  end

  protected

  def set_rsvp_sessions
    session_ids = params[:rsvp_sessions].present? ? params[:rsvp_sessions].map(&:to_i) : []
    @rsvp.set_attending_sessions(session_ids)
  end

  def load_rsvp
    @rsvp = Rsvp.find_by_id(params[:id])
    redirect_to events_path, notice: 'You are not signed up to volunteer for this event' and return unless @rsvp
    false
  end

end