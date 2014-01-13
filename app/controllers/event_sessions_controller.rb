class EventSessionsController < ApplicationController
  before_filter :authenticate_user!, :find_event, :validate_checkiner!
  skip_before_filter :verify_authenticity_token, :validate_checkiner!, :authenticate_user!, :protect_from_forgery, only: :show

  def index
    @checkin_counts = @event.checkin_counts
  end

  def show
    event_session = EventSession.find(params[:id])
    ics = IcsGenerator.new.event_session_ics(event_session)

    respond_to do |format|
      format.ics { render text: ics, layout: false }
      format.all { head status: 404 }
    end
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
