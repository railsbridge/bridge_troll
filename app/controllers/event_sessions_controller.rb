class EventSessionsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :find_event

  def index
    authorize @event, :checkin?
    @checkin_counts = @event.checkin_counts
  end

  def show
    skip_authorization
    event_session = @event.event_sessions.find(params[:id])
    ics = IcsGenerator.new.event_session_ics(event_session)

    respond_to do |format|
      format.ics { render body: ics, layout: false }
      format.all { head 404 }
    end
  end

  def destroy
    authorize @event, :edit?
    event_session = @event.event_sessions.find(params[:id])
    if @event.event_sessions.count > 1 && !event_session.has_rsvps?
      event_session.destroy
      flash[:notice] = "Session #{event_session.name} deleted!"
    else
      flash[:notice] = "Can't delete that session!"
    end
    redirect_to edit_event_path(@event)
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
