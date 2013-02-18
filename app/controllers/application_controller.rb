class ApplicationController < ActionController::Base
  protect_from_forgery

  def validate_organizer!
    @event = Event.find(params[:event_id])
    organizer = @event.organizer?(current_user) || current_user.admin?

    unless organizer
      redirect_to events_path
      false
    end
  end
end
