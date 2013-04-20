class CheckinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!
  before_filter :find_rsvp_session, only: [:create, :destroy]

  def index
    @event = Event.find(params[:event_id])
    @session = @event.event_sessions.find(params[:event_session_id])
    @rsvp_sessions = @session.rsvp_sessions.joins(
        :rsvp => :bridgetroll_user
    ).order('users.first_name asc, users.last_name asc, users.email asc')
  end

  def create
    @rsvp_session.checked_in = true
    @rsvp_session.save!

    redirect_to event_event_session_checkins_path
  end

  def destroy
    @rsvp_session.checked_in = false
    @rsvp_session.save!

    redirect_to event_event_session_checkins_path
  end

  private

  def find_rsvp_session
    @event = Event.find(params[:event_id])
    @session = @event.event_sessions.find(params[:event_session_id])

    @rsvp_session = @session.rsvp_sessions.find(params[:rsvp_session][:id])
  end
end