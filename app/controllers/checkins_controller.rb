class CheckinsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event_and_session
  before_action :find_rsvp_session, only: [:create, :destroy]

  def index
    authorize @event, :checkin?
    @rsvp_sessions = @session.rsvp_sessions.joins(
      rsvp: :bridgetroll_user
    ).includes([rsvp: :user]).order('users.first_name asc, users.last_name asc, users.email asc')
    respond_to do |format|
      format.html { @checkin_counts = @event.checkin_counts }
      format.json { render json: @rsvp_sessions }
    end
  end

  def create
    authorize @event, :checkin?
    @rsvp_session.checked_in = true
    @rsvp_session.save!

    render json: @event.checkin_counts
  end

  def destroy
    authorize @event, :checkin?
    @rsvp_session.checked_in = false
    @rsvp_session.save!

    render json: @event.checkin_counts
  end

  private

  def find_event_and_session
    @event = Event.find(params[:event_id])
    @session = @event.event_sessions.find(params[:event_session_id])
  end

  def rsvp_sessions_with_rsvp
    @session.rsvp_sessions.includes(:rsvp)
  end

  def find_rsvp_session
    @rsvp_session = @session.rsvp_sessions.find(params[:id] || params[:rsvp_session][:id])
  end
end