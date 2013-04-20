class CheckinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_organizer!
  before_filter :find_event_and_session
  before_filter :find_rsvp_session, only: [:create, :destroy]

  def index
    @rsvp_sessions = @session.rsvp_sessions.joins(
        :rsvp => :bridgetroll_user
    ).order('users.first_name asc, users.last_name asc, users.email asc')
  end

  def create
    @rsvp_session.checked_in = true
    @rsvp_session.save!

    render json: {checked_in_count: @session.rsvp_sessions.where(:checked_in=>true).length }
  end

  def destroy
    @rsvp_session.checked_in = false
    @rsvp_session.save!

    render json: {checked_in_count: @session.rsvp_sessions.where(:checked_in=>true).length }
  end

  private

  def find_event_and_session
    @event = Event.find(params[:event_id])
    @session = @event.event_sessions.find(params[:event_session_id])
  end

  def find_rsvp_session
    @rsvp_session = @session.rsvp_sessions.find(params[:rsvp_session][:id])
  end
end