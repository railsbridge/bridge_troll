class RsvpsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_event
  before_filter :load_rsvp, except: [:volunteer, :learn, :create]

  def volunteer
    @rsvp = @event.rsvps.build(role: Role::VOLUNTEER)
    render :new
  end

  def learn
    @rsvp = @event.rsvps.build(role: Role::STUDENT)
    render :new
  end

  def create
    @rsvp = Rsvp.new(params[:rsvp])
    @rsvp.event = @event
    @rsvp.user = current_user

    if @rsvp.save
      set_rsvp_sessions
      RsvpMailer.confirm_volunteer(@rsvp).deliver
      redirect_to @event, notice: 'Thanks for signing up!'
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
    redirect_to events_path, notice: "You are now no longer signed up for #{@event.title}"
  end

  protected

  def set_rsvp_sessions
    session_ids = params[:rsvp_sessions].present? ? params[:rsvp_sessions].map(&:to_i) : []
    @rsvp.set_attending_sessions(session_ids)
  end

  def load_rsvp
    @rsvp = Rsvp.find_by_id(params[:id])
    redirect_to events_path, notice: 'You are not signed up for this event' and return unless @rsvp
    false
  end

  def assign_event
    @event = Event.find_by_id(params[:event_id])
  end
end
