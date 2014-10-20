class CheckinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_event_and_session
  before_filter :validate_checkiner!
  before_filter :find_rsvp_session, only: [:create, :destroy]

  def index
    @rsvp_sessions = @session.rsvp_sessions.joins(
        :rsvp => :bridgetroll_user
    ).order('users.first_name asc, users.last_name asc, users.email asc')
    respond_to do |format|
      format.html { @checkin_counts = checkin_counts }
      format.json { render json: @rsvp_sessions }
    end
  end

  def create
    @rsvp_session.checked_in = true
    @rsvp_session.save!

    render json: checkin_counts
  end

  def destroy
    @rsvp_session.checked_in = false
    @rsvp_session.save!

    render json: checkin_counts
  end

  private

  def find_event_and_session
    @event = Event.find(params[:event_id])
    @session = @event.event_sessions.find(params[:event_session_id])
  end

  def rsvp_sessions_with_rsvp
    @session.rsvp_sessions.includes(:rsvp)
  end

  def checkin_counts
    checked_in_rsvps = @session.rsvp_sessions.joins(:rsvp).where(checked_in: true)
    {
      student_checked_in_count: checked_in_rsvps.where('rsvps.role_id = ?', Role::STUDENT.id).length,
      volunteer_checked_in_count: checked_in_rsvps.where('rsvps.role_id = ?', Role::VOLUNTEER.id).length
    }
  end

  def find_rsvp_session
    @rsvp_session = @session.rsvp_sessions.find(params[:rsvp_session][:id])
  end
end