class RsvpsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_event
  before_filter :load_rsvp, except: [:new, :create]

  def new
    @rsvp = @event.rsvps.build
  end

  def create
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.event = @event
    @rsvp.user = current_user
    @rsvp.role = Role::VOLUNTEER

    if @rsvp.save
      set_rsvp_sessions
      redirect_to @event, notice: 'Thanks for volunteering!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @rsvp.update_attributes(params[:rsvp])
      set_rsvp_sessions
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    @rsvp.destroy
    redirect_to events_path, notice: "You are now no longer signed up to volunteer for #{@event.title}"
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

  def assign_event
    @event = Event.find_by_id(params[:event_id])
  end
end